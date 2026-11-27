#!/usr/bin/env python3
"""Validate the development-autonomy permission map and its mirrors.

Checks:
  1. resolution matrix (last-matching-rule-wins) against sample commands
  2. repo opencode.json bash map == canonical scripts/autonomy-map.json
  3. omni-orchestrator.md frontmatter == canonical map
  4. all dev-loop agents' frontmatter == canonical map
  5. global ~/.config/opencode/opencode.jsonc == canonical map (skipped with
     --no-global, or when the file is absent — e.g. in CI)

Exit 0 = all good; exit 1 = mismatch or unexpected resolution.
"""
import fnmatch
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent

DEV_AGENTS = [
    "backend-rust-engineer", "backend-python-engineer", "backend-csharp-engineer",
    "frontend-vue-engineer", "frontend-react-engineer", "unit-test-generator",
    "integration-tester", "e2e-test-engineer", "load-simulator", "qa-validator",
    "uat-mimic", "accessibility-auditor", "data-migration-engineer",
    "local-env-engineer", "pr-validator", "github-operator", "release-manager",
    "codebase-explorer", "traceability-keeper", "technical-writer", "solution-architect",
]

MATRIX = [
    # reads / checks
    ("git status --porcelain", "allow"),
    ("git log --oneline -5", "allow"),
    ("git diff HEAD", "allow"),
    ("git switch develop", "allow"),
    ("git pull --ff-only", "allow"),
    ("ls -la", "allow"),
    ("cat README.md", "allow"),
    ("diff a b", "allow"),
    ("ss -ltnp", "allow"),
    ("df -h /tmp", "allow"),
    ("python3 -m json.tool opencode.json", "allow"),
    ("bash -n scripts/install.sh", "allow"),
    # local mutations / feature pushes
    ("git add -A", "allow"),
    ('git commit -m "msg"', "allow"),
    ("git checkout -b feature/x", "allow"),
    ("git push origin feature/REQ-014-x", "allow"),
    ("git push -u origin feature/x", "allow"),
    # CI / read-only GitHub
    ("gh run list --limit 5", "allow"),
    ("gh run view 123", "allow"),
    ("gh pr checks 7", "allow"),
    # project scripts / tests / builds
    ("bash scripts/dev-up.sh", "allow"),
    ("bash scripts/db-migrate.sh", "allow"),
    ("bash docs/qa/migrate.sh", "allow"),
    ("npx vitest run src/x.spec.ts", "allow"),
    ("npm test", "allow"),
    ("cargo test", "allow"),
    ("cargo clippy -- -D warnings", "allow"),
    ("dotnet build", "allow"),
    ("pytest -q", "allow"),
    # local service inspection / health
    ("docker ps", "allow"),
    ("docker logs app", "allow"),
    ("curl http://127.0.0.1:8080/health", "allow"),
    # ask
    ("rm foo.txt", "ask"),
    ("mv a b", "ask"),
    ("curl https://example.com", "ask"),
    ("docker compose up -d", "ask"),
    ("psql -c 'select 1'", "ask"),
    ("npm install left-pad", "ask"),
    ("npm run dev", "ask"),
    ("git push origin develop", "ask"),
    ("git checkout main", "ask"),
    ("git reset HEAD~1", "ask"),
    # deny
    ("rm -rf /tmp/x", "deny"),
    ("git push --force origin main", "deny"),
    ("git push -f origin x", "deny"),
    ("git push origin feature/x --force", "deny"),
    ("git push origin :feature/x", "deny"),
    ("git remote add origin x", "deny"),
    ("gh repo create x", "deny"),
    ("sudo rm x", "deny"),
]


def resolve(cmd: str, rules: dict) -> str | None:
    action = None
    for pattern, act in rules.items():
        if fnmatch.fnmatchcase(cmd, pattern):
            action = act
    return action


def load_json(path: Path) -> dict:
    text = path.read_text()
    if path.suffix == ".jsonc":
        text = re.sub(r"^\s*//.*$", "", text, flags=re.M)
        text = re.sub(r",(\s*[}\]])", r"\1", text)
    return json.loads(text)


def frontmatter_map(path: Path) -> dict | None:
    try:
        import yaml  # type: ignore
    except ImportError:
        return None
    text = path.read_text()
    fm = text.split("---")[1]
    data = yaml.safe_load(fm)
    return data.get("permission", {}).get("bash")


def main() -> int:
    no_global = "--no-global" in sys.argv
    canonical = dict(json.loads((HERE / "autonomy-map.json").read_text())["bash"])
    failures = 0

    # 1. matrix
    for cmd, expected in MATRIX:
        got = resolve(cmd, canonical)
        if got != expected:
            print(f"[x] '{cmd}' -> {got} (expected {expected})")
            failures += 1
    if not failures:
        print(f"[+] permission matrix OK ({len(MATRIX)} commands, {len(canonical)} rules)")

    # 2. repo config
    repo_map = load_json(REPO / "opencode.json")["permission"]["bash"]
    if repo_map != canonical:
        print("[x] opencode.json bash map differs from scripts/autonomy-map.json")
        failures += 1
    else:
        print("[+] opencode.json map in sync")

    # 3. orchestrator frontmatter
    orch = frontmatter_map(REPO / ".opencode/agent/omni-orchestrator.md")
    if orch is None:
        print("[!] PyYAML not available — skipping frontmatter checks")
    elif orch != canonical:
        print("[x] omni-orchestrator.md frontmatter differs from canonical map")
        failures += 1
    else:
        print("[+] omni-orchestrator.md frontmatter in sync")

    # 4. dev-loop agents
    if orch is not None:
        bad = []
        for name in DEV_AGENTS:
            m = frontmatter_map(REPO / ".opencode/agent" / f"{name}.md")
            if m != canonical:
                bad.append(name)
        if bad:
            print(f"[x] dev agents out of sync: {bad}")
            failures += 1
        else:
            print(f"[+] {len(DEV_AGENTS)} dev agents in sync")

    # 5. global config
    if not no_global:
        gl = Path.home() / ".config/opencode/opencode.jsonc"
        if gl.exists():
            gmap = load_json(gl)["permission"]["bash"]
            if gmap != canonical:
                print("[x] global opencode.jsonc map differs (run the global sync)")
                failures += 1
            else:
                print("[+] global opencode.jsonc map in sync")
        else:
            print("[i] global config not present — skipped")

    if failures:
        print(f"\n{failures} problem(s) found")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
