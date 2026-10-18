#!/usr/bin/env fish
# Omni Project Setup Script (Fish Shell)
# Creates all files needed for a new project to use omni-agent-builder
# Usage: ./setup-omni-project.fish [project-name]

function print_info
    set_color blue
    echo -n "[i] "
    set_color normal
    echo $argv
end

function print_success
    set_color green
    echo -n "[✓] "
    set_color normal
    echo $argv
end

function print_warning
    set_color yellow
    echo -n "[!] "
    set_color normal
    echo $argv
end

function print_error
    set_color red
    echo -n "[✗] "
    set_color normal
    echo $argv
end

function print_header
    echo ""
    set_color cyan
    echo "═══ $argv[1] ═══"
    set_color normal
    echo ""
end

# Get project name
print_header "Omni Project Setup"
if test (count $argv) -ge 1
    set PRODUCT_NAME $argv[1]
else
    echo -n (set_color blue)"Project name: "(set_color normal)
    read PRODUCT_NAME
end

if test -z "$PRODUCT_NAME"
    print_error "Project name is required"
    exit 1
end

# Get GitHub org/username
print_header "GitHub Configuration"
echo -n (set_color blue)"GitHub org/username (or press Enter for placeholder): "(set_color normal)
read GITHUB_ORG
test -z "$GITHUB_ORG"; and set GITHUB_ORG "YOUR_ORG"

# Get base clone path (required — the user's choice, no default)
print_info "Product repos will be cloned under a base directory of your choice (any directory you own; it does not need to exist yet)."
while true
    echo -n (set_color blue)"Base clone path (required, e.g. ~/my-projects): "(set_color normal)
    read CLONE_BASE
    if test -n "$CLONE_BASE"
        break
    end
    print_warning "Base clone path is required — please enter a directory."
end
set CLONE_BASE (string replace '~' "$HOME" $CLONE_BASE)

# Ask which repos to create
print_header "Repository Selection"
echo "Select which repos to register (y/n):"
echo ""

echo -n (set_color blue)"  decision_logs (requirements, ADRs, traceability) [Y/n]: "(set_color normal)
read ADD_DECISION
test -z "$ADD_DECISION"; and set ADD_DECISION Y

echo -n (set_color blue)"  ui_design (wireframes, design tokens) [Y/n]: "(set_color normal)
read ADD_UI
test -z "$ADD_UI"; and set ADD_UI Y

echo -n (set_color blue)"  frontend [Y/n]: "(set_color normal)
read ADD_FRONTEND
test -z "$ADD_FRONTEND"; and set ADD_FRONTEND Y

echo -n (set_color blue)"  backend [Y/n]: "(set_color normal)
read ADD_BACKEND
test -z "$ADD_BACKEND"; and set ADD_BACKEND Y

echo -n (set_color blue)"  legacy (for as-is analysis) [y/N]: "(set_color normal)
read ADD_LEGACY
test -z "$ADD_LEGACY"; and set ADD_LEGACY N

# Create directory structure
print_header "Creating Files"
mkdir -p .omni
print_success "Created .omni/"

# Create opencode.json
printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "default_agent": "omni-orchestrator"\n}\n' > opencode.json
print_success "Created opencode.json"

# Build repos JSON
set REPOS ""

if test (string upper $ADD_DECISION) = "Y"
    set REPOS "        \"decision_logs\": {
          \"ssh_url\": \"git@github.com:{$GITHUB_ORG}/{$PRODUCT_NAME}-decisions.git\",
          \"local_path\": \"{$CLONE_BASE}/{$PRODUCT_NAME}-decisions\",
          \"purpose\": \"strategy, requirements, ADRs, traceability, release notes\"
        }"
end

if test (string upper $ADD_UI) = "Y"
    if test -n "$REPOS"
        set REPOS "$REPOS,
"
    end
    set REPOS "$REPOS        \"ui_design\": {
          \"ssh_url\": \"git@github.com:{$GITHUB_ORG}/{$PRODUCT_NAME}-ui.git\",
          \"local_path\": \"{$CLONE_BASE}/{$PRODUCT_NAME}-ui\",
          \"purpose\": \"wireframes, design tokens, UX specs, exported prototypes\"
        }"
end

if test (string upper $ADD_FRONTEND) = "Y"
    if test -n "$REPOS"
        set REPOS "$REPOS,
"
    end
    set REPOS "$REPOS        \"frontend\": {
          \"ssh_url\": \"git@github.com:{$GITHUB_ORG}/{$PRODUCT_NAME}-frontend.git\",
          \"local_path\": \"{$CLONE_BASE}/{$PRODUCT_NAME}-frontend\",
          \"purpose\": \"frontend source code\"
        }"
end

if test (string upper $ADD_BACKEND) = "Y"
    if test -n "$REPOS"
        set REPOS "$REPOS,
"
    end
    set REPOS "$REPOS        \"backend\": {
          \"ssh_url\": \"git@github.com:{$GITHUB_ORG}/{$PRODUCT_NAME}-backend.git\",
          \"local_path\": \"{$CLONE_BASE}/{$PRODUCT_NAME}-backend\",
          \"purpose\": \"backend source code\"
        }"
end

if test (string upper $ADD_LEGACY) = "Y"
    if test -n "$REPOS"
        set REPOS "$REPOS,
"
    end
    set REPOS "$REPOS        \"legacy\": {
          \"ssh_url\": \"git@github.com:{$GITHUB_ORG}/{$PRODUCT_NAME}-legacy.git\",
          \"local_path\": \"{$CLONE_BASE}/{$PRODUCT_NAME}-legacy\",
          \"purpose\": \"legacy source code for as-is analysis\"
        }"
end

# Create orchestrator.config.json
printf '{
  "$schema": "./repo-registry.schema.json",
  "projects": {
    "%s": {
      "clone_base_path": "%s",
      "stack_selection_mode": "always_ask",
      "repos": {
%s
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
}
' "$PRODUCT_NAME" "$CLONE_BASE" "$REPOS" > .omni/orchestrator.config.json
print_success "Created .omni/orchestrator.config.json"

# Copy repo-registry schema (global install first, then repo-relative fallback)
set SCRIPT_DIR (dirname (status --current-filename))
set SCHEMA_SOURCE "$HOME/.config/opencode/instructions/repo-registry.schema.json"
if not test -f "$SCHEMA_SOURCE"
    set SCHEMA_SOURCE "$SCRIPT_DIR/../.omni/repo-registry.schema.json"
end

if test -f "$SCHEMA_SOURCE"
    cp "$SCHEMA_SOURCE" .omni/
    print_success "Created .omni/repo-registry.schema.json"
else
    print_warning "repo-registry.schema.json not found - you may need to copy it manually"
end

# Summary
print_header "Setup Complete"
set_color green
echo "Project '$PRODUCT_NAME' is ready!"
set_color normal
echo ""
echo "Files created:"
echo "  • opencode.json"
echo "  • .omni/orchestrator.config.json"
echo "  • .omni/repo-registry.schema.json"
echo ""
echo "Registered repos:"
test (string upper $ADD_DECISION) = "Y"; and echo "  • $PRODUCT_NAME-decisions (decision_logs)"
test (string upper $ADD_UI) = "Y"; and echo "  • $PRODUCT_NAME-ui (ui_design)"
test (string upper $ADD_FRONTEND) = "Y"; and echo "  • $PRODUCT_NAME-frontend (frontend)"
test (string upper $ADD_BACKEND) = "Y"; and echo "  • $PRODUCT_NAME-backend (backend)"
test (string upper $ADD_LEGACY) = "Y"; and echo "  • $PRODUCT_NAME-legacy (legacy)"
echo ""
echo "Next steps:"
echo "  1. Update .omni/orchestrator.config.json with real GitHub URLs (when available)"
echo "  2. Run: opencode"
echo "  3. Use /omni-onboard-product to register repos"
echo ""
