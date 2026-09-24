#!/usr/bin/env bash
# Omni Agent Builder - Global Installer (bash)
# Installs the setup-omni scripts so they are available on PATH from any shell.
#
# Usage:
#   git clone <repo-url> omni-agent-builder
#   cd omni-agent-builder && ./scripts/install.sh
#
# Installs to:
#   ~/.config/opencode/setup-omni-project.sh
#   ~/.config/opencode/setup-omni-project.fish
#   ~/.config/opencode/instructions/repo-registry.schema.json  (if missing)
#   ~/.local/bin/setup-omni        -> setup-omni-project.sh
#   ~/.local/bin/setup-omni.fish   -> setup-omni-project.fish

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info()    { echo -e "${BLUE}[i]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.config/opencode"
BIN_DIR="$HOME/.local/bin"

echo -e "${BLUE}═══ Omni Agent Builder - Global Install ═══${NC}"
echo ""
print_info "Repo: $REPO_DIR"

# Validate source files exist
for f in setup-omni-project.sh setup-omni-project.fish; do
    if [ ! -f "$REPO_DIR/scripts/$f" ]; then
        print_error "Missing: $REPO_DIR/scripts/$f"
        exit 1
    fi
done

# Install scripts
mkdir -p "$DEST" "$BIN_DIR"
install -m 755 "$REPO_DIR/scripts/setup-omni-project.sh"  "$DEST/setup-omni-project.sh"
install -m 755 "$REPO_DIR/scripts/setup-omni-project.fish" "$DEST/setup-omni-project.fish"
print_success "Installed setup-omni-project.sh  -> $DEST/"
print_success "Installed setup-omni-project.fish -> $DEST/"

# Install schema (do not overwrite an existing customized copy)
SCHEMA_SRC="$REPO_DIR/.omni/repo-registry.schema.json"
SCHEMA_DST="$DEST/instructions/repo-registry.schema.json"
if [ -f "$SCHEMA_SRC" ]; then
    if [ -f "$SCHEMA_DST" ]; then
        print_info "Schema already exists, keeping: $SCHEMA_DST"
    else
        mkdir -p "$DEST/instructions"
        install -m 644 "$SCHEMA_SRC" "$SCHEMA_DST"
        print_success "Installed repo-registry.schema.json -> $DEST/instructions/"
    fi
else
    print_warning "No schema found at $SCHEMA_SRC (skipped)"
fi

# PATH entry points
ln -sfn "$DEST/setup-omni-project.sh"  "$BIN_DIR/setup-omni"
ln -sfn "$DEST/setup-omni-project.fish" "$BIN_DIR/setup-omni.fish"
print_success "Linked $BIN_DIR/setup-omni"
print_success "Linked $BIN_DIR/setup-omni.fish"

# PATH check
case ":$PATH:" in
    *":$BIN_DIR:"*)
        print_success "\$HOME/.local/bin is on PATH"
        ;;
    *)
        print_warning "\$HOME/.local/bin is NOT on PATH"
        echo "       Add to your shell profile:"
        echo "         bash/zsh:  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "         fish:      fish_add_path \$HOME/.local/bin"
        ;;
esac

echo ""
print_success "Install complete!"
echo ""
echo "Usage (from any project directory):"
echo "  setup-omni            # bash/zsh"
echo "  setup-omni.fish       # fish"
echo ""
