#!/usr/bin/env bash
# Omni Project Setup Script
# Creates all files needed for a new project to use omni-agent-builder
# Usage: ./setup-omni-project.sh [project-name]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_header() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }

# Get project name
print_header "Omni Project Setup"
if [ -n "${1:-}" ]; then
    PRODUCT_NAME="$1"
else
    read -p "$(echo -e "${BLUE}Project name: ${NC}")" PRODUCT_NAME
fi

if [ -z "$PRODUCT_NAME" ]; then
    print_error "Project name is required"
    exit 1
fi

# Get GitHub org/username (optional)
print_header "GitHub Configuration"
read -p "$(echo -e "${BLUE}GitHub org/username (or press Enter for placeholder): ${NC}")" GITHUB_ORG
GITHUB_ORG="${GITHUB_ORG:-YOUR_ORG}"

# Get base clone path
read -p "$(echo -e "${BLUE}Base clone path [~/workspace/roger-projects]: ${NC}")" CLONE_BASE
CLONE_BASE="${CLONE_BASE:-~/workspace/roger-projects}"
CLONE_BASE="${CLONE_BASE/#\~/$HOME}"

# Ask which repos to create
print_header "Repository Selection"
echo "Select which repos to register (y/n):"
echo ""

read -p "$(echo -e "${BLUE}  decision_logs (requirements, ADRs, traceability) [Y/n]: ${NC}")" ADD_DECISION
ADD_DECISION="${ADD_DECISION:-Y}"

read -p "$(echo -e "${BLUE}  ui_design (wireframes, design tokens) [Y/n]: ${NC}")" ADD_UI
ADD_UI="${ADD_UI:-Y}"

read -p "$(echo -e "${BLUE}  frontend [Y/n]: ${NC}")" ADD_FRONTEND
ADD_FRONTEND="${ADD_FRONTEND:-Y}"

read -p "$(echo -e "${BLUE}  backend [Y/n]: ${NC}")" ADD_BACKEND
ADD_BACKEND="${ADD_BACKEND:-Y}"

read -p "$(echo -e "${BLUE}  legacy (for as-is analysis) [y/N]: ${NC}")" ADD_LEGACY
ADD_LEGACY="${ADD_LEGACY:-N}"

# Create directory structure
print_header "Creating Files"
mkdir -p .omni
print_success "Created .omni/"

# Create opencode.json
cat > opencode.json <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "omni-orchestrator"
}
EOF
print_success "Created opencode.json"

# Build orchestrator config JSON
CONFIG='{
  "$schema": "./repo-registry.schema.json",
  "projects": {
    "'"$PRODUCT_NAME"'": {
      "clone_base_path": "'"$CLONE_BASE"'",
      "stack_selection_mode": "always_ask",
      "repos": {'

FIRST=true

add_repo() {
    local key=$1 name=$2 purpose=$3 add_var=$4
    if [[ "${!add_var:-}" =~ ^[Yy] ]]; then
        [ "$FIRST" = false ] && CONFIG+=","
        CONFIG+='
        "'"$key"'": {
          "ssh_url": "git@github.com:'"$GITHUB_ORG/$PRODUCT_NAME-$name.git"'",
          "local_path": "'"$CLONE_BASE/$PRODUCT_NAME-$name"'",
          "purpose": "'"$purpose"'"
        }'
        FIRST=false
    fi
}

add_repo "decision_logs" "decisions" "strategy, requirements, ADRs, traceability, release notes" ADD_DECISION
add_repo "ui_design" "ui" "wireframes, design tokens, UX specs, exported prototypes" ADD_UI
add_repo "frontend" "frontend" "frontend source code" ADD_FRONTEND
add_repo "backend" "backend" "backend source code" ADD_BACKEND
add_repo "legacy" "legacy" "legacy source code for as-is analysis" ADD_LEGACY

CONFIG+='
      },
      "branch_strategy": {
        "development": "develop",
        "release_prefix": "release/",
        "production": "main"
      },
      "github": {
        "api_auth_env": "GITHUB_TOKEN",
        "auto_merge_to_develop": true,
        "human_approval_required_for_main": true
      }
    }
  }
}'

echo "$CONFIG" > .omni/orchestrator.config.json
print_success "Created .omni/orchestrator.config.json"

# Copy repo-registry schema (global install first, then repo-relative fallback)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_SOURCE="$HOME/.config/opencode/instructions/repo-registry.schema.json"
if [ ! -f "$SCHEMA_SOURCE" ]; then
    SCHEMA_SOURCE="$SCRIPT_DIR/../.omni/repo-registry.schema.json"
fi

if [ -f "$SCHEMA_SOURCE" ]; then
    cp "$SCHEMA_SOURCE" .omni/
    print_success "Created .omni/repo-registry.schema.json"
else
    print_warning "repo-registry.schema.json not found - you may need to copy it manually"
fi

# Summary
print_header "Setup Complete"
echo -e "${GREEN}Project '${PRODUCT_NAME}' is ready!${NC}"
echo ""
echo "Files created:"
echo "  • opencode.json"
echo "  • .omni/orchestrator.config.json"
echo "  • .omni/repo-registry.schema.json"
echo ""
echo "Registered repos:"
[[ "${ADD_DECISION:-N}" =~ ^[Yy] ]] && echo "  • $PRODUCT_NAME-decisions (decision_logs)"
[[ "${ADD_UI:-N}" =~ ^[Yy] ]] && echo "  • $PRODUCT_NAME-ui (ui_design)"
[[ "${ADD_FRONTEND:-N}" =~ ^[Yy] ]] && echo "  • $PRODUCT_NAME-frontend (frontend)"
[[ "${ADD_BACKEND:-N}" =~ ^[Yy] ]] && echo "  • $PRODUCT_NAME-backend (backend)"
[[ "${ADD_LEGACY:-N}" =~ ^[Yy] ]] && echo "  • $PRODUCT_NAME-legacy (legacy)"
echo ""
echo "Next steps:"
echo "  1. Update .omni/orchestrator.config.json with real GitHub URLs (when available)"
echo "  2. Run: opencode"
echo "  3. Use /omni-onboard-product to register repos"
echo ""
