#!/usr/bin/env python3
"""Generate project-scoped OpenCode permissions from the project registry.

Reads `.omni/orchestrator.config.json` and writes/updates `opencode.json` in the
project directory with:
  - external_directory allows for the project, its registered repos, the clone
    base path, the worktree root, and /tmp/opencode
  - the canonical development-autonomy bash map
  - repo-scoped read-only CI patterns (gh api .../actions/runs*) derived from
    each registered repo's SSH URL

No project or infrastructure name is hardcoded: everything comes from the
registry. Idempotent.

Usage:
  omni-refresh-permissions.py [project-dir] [--check] [--project NAME]
"""
import argparse
import json
import re
import sys
from pathlib import Path

GH_SSH = re.compile(r"^git@github\.com:([^/]+)/([^/]+?)(?:\.git)?$")


def load_map() -> list:
    here = Path(__file__).resolve().parent
    for cand in (here / "autonomy-map.json", here / "scripts" / "autonomy-map.json"):
        if cand.exists():
            return json.loads(cand.read_text())["bash"]
    raise SystemExit("[x] autonomy-map.json not found next to the script")


def expand(p: str) -> Path:
    return Path(p).expanduser().resolve()


def build(project_dir: Path, project: dict, base_map: list) -> tuple[dict, dict]:
    clone_base = expand(project.get("clone_base_path", str(project_dir)))
    repo_paths = [expand(r["local_path"]) for r in project.get("repos", {}).values() if r.get("local_path")]
    wt_root = expand(project.get("worktrees", {}).get("root") or str(project_dir / ".worktrees"))

    ext = {"*": "ask", f"{project_dir}/**": "allow"}
    for p in repo_paths:
        ext[f"{p}/**"] = "allow"
    ext[f"{clone_base}/**"] = "allow"
    ext[f"{wt_root}/**"] = "allow"
    ext["/tmp/opencode/**"] = "allow"

    gh_patterns = []
    for r in project.get("repos", {}).values():
        m = GH_SSH.match(r.get("ssh_url", ""))
        if m:
            owner, repo = m.group(1), m.group(2)
            gh_patterns.append((f"gh api repos/{owner}/{repo}/actions/runs*", "allow"))

    # insert repo-scoped gh patterns after the last generic gh allow
    rules = list(base_map)
    insert_at = 0
    for i, (pat, act) in enumerate(rules):
        if pat.startswith("gh ") and act == "allow":
            insert_at = i + 1
    rules[insert_at:insert_at] = gh_patterns
    return {"bash": dict(rules), "external_directory": ext}, {"repos": len(gh_patterns), "paths": len(ext) - 1}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("project_dir", nargs="?", default=".")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--project", help="project key in the registry (default: first)")
    args = ap.parse_args()

    pdir = Path(args.project_dir).expanduser().resolve()
    cfg_path = pdir / ".omni" / "orchestrator.config.json"
    if not cfg_path.exists():
        print(f"[x] missing {cfg_path}")
        return 2
    cfg = json.loads(cfg_path.read_text())
    projects = cfg.get("projects", {})
    key = args.project or next(iter(projects), None)
    if not key or key not in projects:
        print("[x] no project entry found in the registry")
        return 2
    project = projects[key]

    permissions, stats = build(pdir, project, load_map())

    oc_path = pdir / "opencode.json"
    if oc_path.exists():
        oc = json.loads(oc_path.read_text())
    else:
        oc = {"$schema": "https://opencode.ai/config.json", "default_agent": "omni-orchestrator"}

    current = {
        "bash": oc.get("permission", {}).get("bash"),
        "external_directory": oc.get("permission", {}).get("external_directory"),
    }
    if args.check:
        same = current == permissions
        print(f"[{'ok' if same else 'x'}] {pdir} permissions {'in sync' if same else 'OUT OF SYNC'}")
        if not same:
            print("    run without --check to regenerate")
        return 0 if same else 1

    perm = oc.setdefault("permission", {})
    perm["bash"] = permissions["bash"]
    perm["external_directory"] = permissions["external_directory"]
    oc_path.write_text(json.dumps(oc, indent=2) + "\n")
    print(f"[ok] wrote {oc_path}")
    print(f"     project={key} repos-patterns={stats['repos']} external-paths={stats['paths']}")
    print("     restart OpenCode to apply")
    return 0


if __name__ == "__main__":
    sys.exit(main())
