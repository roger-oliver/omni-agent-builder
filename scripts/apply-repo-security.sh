#!/usr/bin/env bash
# apply-repo-security.sh — protect roger-oliver/omni-agent-builder for public use.
#
# What it does (idempotent; safe to re-run):
#   1. Preflight: token must SEE the repo and have ADMIN permission.
#   2. Repo settings: merge-commit only (no squash/rebase), no auto-merge,
#      delete branches on merge, disable wiki/projects (attack surface).
#   3. Branch protection on main + develop:
#        - PRs required; direct pushes blocked for non-admins
#        - enforce_admins=false  -> the OWNER (you) may still push directly
#        - 1 approving review + CODEOWNER approval required
#        - required status check: omni-validate (from .github/workflows/validate.yml)
#        - no force-push, no branch deletion, conversation must resolve
#   4. Enables private vulnerability reporting (SECURITY.md flow).
#
# Usage:
#   ./scripts/apply-repo-security.sh            # apply
#   ./scripts/apply-repo-security.sh --check    # report current state only
#
# Requirements: gh (authenticated), repo added to your fine-grained PAT with
#   "Administration: Read and write" (see preflight error for instructions).

set -euo pipefail

OWNER="${OMNI_REPO_OWNER:-roger-oliver}"
REPO="${OMNI_REPO_NAME:-omni-agent-builder}"
API="repos/${OWNER}/${REPO}"
BRANCHES=(main develop)
CHECK_CONTEXT="omni-validate"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }

MODE="apply"
[ "${1:-}" = "--check" ] && MODE="check"

# ---------- 1. Preflight ----------
if ! command -v gh >/dev/null 2>&1; then
    err "gh CLI not found. Install GitHub CLI first."
    exit 1
fi

if ! REPO_JSON=$(gh api "$API" 2>/dev/null); then
    err "Token cannot see ${OWNER}/${REPO} (404)."
    echo "  If the repo is private: add it to your fine-grained PAT"
    echo "  (Settings > Developer settings > Fine-grained tokens > Repository access"
    echo "  > Only select repositories > ${OWNER}/${REPO}) and grant"
    echo "  'Administration: Read and write', then re-run this script."
    exit 1
fi

ADMIN=$(python3 -c "import json,sys; print(json.loads(sys.stdin.read())['permissions']['admin'])" <<< "$REPO_JSON")
if [ "$ADMIN" != "True" ]; then
    err "Token can see the repo but lacks admin permission."
    echo "  Grant 'Administration: Read and write' on the fine-grained PAT, then re-run."
    exit 1
fi
ok "Preflight: repo visible, token has admin"

VISIBILITY=$(python3 -c "import json,sys; print('private' if json.loads(sys.stdin.read())['private'] else 'public')" <<< "$REPO_JSON")
if [ "$VISIBILITY" = "private" ]; then
    warn "Repo is currently PRIVATE. Branch protection applies now and keeps"
    warn "working when you make it public (visibility change is yours to do:"
    warn "Settings > General > Danger Zone > Change visibility)."
fi

# ---------- helpers ----------
apply_repo_settings() {
    gh api -X PATCH "$API" \
        -f allow_squash_merge=false \
        -f allow_rebase_merge=false \
        -f allow_merge_commit=true \
        -f allow_auto_merge=false \
        -f delete_branch_on_merge=true \
        -f allow_update_branch=true \
        -f has_wiki=false \
        -f has_projects=false > /dev/null
    ok "Repo settings: merge-commits only, no auto-merge, wiki/projects disabled"
}

apply_branch_protection() {
    local br="$1"
    local payload
    payload=$(cat <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["${CHECK_CONTEXT}"] },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true,
  "lock_branch": false
}
JSON
)
    echo "$payload" | gh api -X PUT "${API}/branches/${br}/protection" --input - > /dev/null
    ok "Branch protection applied: ${br} (PRs required, owner may push directly)"
}

check_branch_protection() {
    local br="$1"
    if PROT=$(gh api "${API}/branches/${br}/protection" 2>/dev/null); then
        echo "$PROT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
rpr=d.get('required_pull_request_reviews',{})
print(f\"  ${br}: PRs required (reviews={rpr.get('required_approving_review_count')}, codeowners={rpr.get('require_code_owner_reviews')}), \"
      f\"force-push={d.get('allow_force_pushes',{}).get('enabled')}, deletions={d.get('allow_deletions',{}).get('enabled')}, \"
      f\"admin-enforced={d.get('enforce_admins',{}).get('enabled')}, checks={[c['context'] for c in d.get('required_status_checks',{}).get('contexts',[])]}\")
"
    else
        warn "  ${br}: NO PROTECTION"
    fi
}

# ---------- 2/3. Apply or check ----------
if [ "$MODE" = "check" ]; then
    echo "Current state of ${OWNER}/${REPO}:"
    gh api "$API" --jq '"  merge: commit=" + (.allow_merge_commit|tostring) + " squash=" + (.allow_squash_merge|tostring) + " rebase=" + (.allow_rebase_merge|tostring) + " auto-merge=" + (.allow_auto_merge|tostring)'
    for br in "${BRANCHES[@]}"; do check_branch_protection "$br"; done
    exit 0
fi

apply_repo_settings
for br in "${BRANCHES[@]}"; do
    apply_branch_protection "$br"
done

# ---------- 4. Private vulnerability reporting ----------
if gh api -X PUT "${API}/private-vulnerability-reporting" > /dev/null 2>&1; then
    ok "Private vulnerability reporting enabled"
else
    warn "Could not enable private vulnerability reporting via API."
    echo "  Enable manually: Security > Insights/Settings > Private vulnerability reporting."
fi

# ---------- verify ----------
echo ""
ok "Done. Verifying:"
gh api "$API" --jq '"  merge-commit-only: commit=" + (.allow_merge_commit|tostring) + " squash=" + (.allow_squash_merge|tostring) + " rebase=" + (.allow_rebase_merge|tostring)'
for br in "${BRANCHES[@]}"; do check_branch_protection "$br"; done
echo ""
echo "Notes:"
echo "  - enforce_admins=false: you (admin/owner) can still push directly."
echo "  - Everyone else: fork + PR only; 1 approval + CODEOWNERS + omni-validate check required."
echo "  - Re-run with --check anytime."
