#!/usr/bin/env python3
"""Validate the autonomy permission map and its mirrors.

1. Simulates last-matching-rule-wins against a sample command matrix
   (approximation of OpenCode's parsed-command matching).
2. Checks that the bash map in opencode.json, the global opencode.jsonc
   (when present) and omni-orchestrator.md frontmatter are identical.

Exit 0 = all good; exit 1 = unexpected simulation result or map mismatch.
"""
import fnmatch
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]

MATRIX = [
    # (command, expected action)
    ("git status --porcelain", "allow"),
    ("git log --oneline -5", "allow"),
    ("git diff HEAD", "allow"),
    ("git show HEAD", "allow"),
    ("git fetch origin", "allow"),
    ("git add -A", "allow"),
    ('git commit -m "msg"', "allow"),
    ("git push origin feature/REQ-014-x", "allow"),
    ("git push -u origin feature/x", "allow"),
    ("git switch develop", "allow"),
    ("ls -la", "allow"),
    ("cat README.md", "allow"),
    ("python3 -m json.tool opencode.json", "allow"),
    ("bash -n scripts/install.sh", "allow"),
    ("grep -rn TODO .", "allow"),
    ("rm foo.txt", "ask"),
    ("mv a b", "ask"),
    ("cp a b", "ask"),
    ("curl https://example.com", "ask"),
    ("git push origin develop", "ask"),
    ("git merge main", "ask"),
    ("git checkout main", "ask"),
    ("git reset HEAD~1", "ask"),
    ("git config --global user.email x", "ask"),
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


def load_frontmatter_map(path: Path) -> dict | None:
    try:
        import yaml  # type: ignore
    except ImportError:
        print("[!] PyYAML not available - skipping frontmatter check")
        return None
    text = path.read_text()
    fm = text.split("---")[1]
    data = yaml.safe_load(fm)
    return data.get("permission", {}).get("bash")


def main() -> int:
    failures = 0

    # 1. Simulation matrix
    repo_map = load_json(REPO / "opencode.json")["permission"]["bash"]
    for cmd, expected in MATRIX:
        got = resolve(cmd, repo_map)
        if got != expected:
            print(f"[x] '{cmd}' -> {got} (expected {expected})")
            failures += 1
    if failures == 0:
        print(f"[+] permission matrix OK ({len(MATRIX)} commands, {len(repo_map)} rules)")

    # 2. Mirror sync checks
    global_path = Path.home() / ".config/opencode/opencode.jsonc"
    if global_path.exists():
        gmap = load_json(global_path)["permission"]["bash"]
        if gmap != repo_map:
            print("[x] global opencode.jsonc bash map differs from opencode.json")
            failures += 1
        else:
            print("[+] global opencode.jsonc map in sync")

    fm_map = load_frontmatter_map(REPO / ".opencode/agent/omni-orchestrator.md")
    if fm_map is not None:
        if fm_map != repo_map:
            print("[x] omni-orchestrator.md frontmatter bash map differs from opencode.json")
            failures += 1
        else:
            print("[+] omni-orchestrator.md frontmatter map in sync")

    if failures:
        print(f"\n{failures} problem(s) found")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
