#!/usr/bin/env fish
# Omni Agent Builder - Global Installer (fish)
# Installs the setup-omni scripts so they are available on PATH from any shell.
#
# Usage:
#   git clone <repo-url> omni-agent-builder
#   cd omni-agent-builder && ./scripts/install.fish
#
# Installs to:
#   ~/.config/opencode/setup-omni-project.sh
#   ~/.config/opencode/setup-omni-project.fish
#   ~/.config/opencode/instructions/repo-registry.schema.json  (if missing)
#   ~/.local/bin/setup-omni        -> setup-omni-project.sh
#   ~/.local/bin/setup-omni.fish   -> setup-omni-project.fish

function print_info
    set_color blue; echo -n "[i] "; set_color normal; echo $argv
end
function print_success
    set_color green; echo -n "[✓] "; set_color normal; echo $argv
end
function print_warning
    set_color yellow; echo -n "[!] "; set_color normal; echo $argv
end
function print_error
    set_color red; echo -n "[✗] "; set_color normal; echo $argv
end

set REPO_DIR (dirname (dirname (status --current-filename)))
set REPO_DIR (cd $REPO_DIR; and pwd)
set DEST "$HOME/.config/opencode"
set BIN_DIR "$HOME/.local/bin"

set_color blue; echo "═══ Omni Agent Builder - Global Install ═══"; set_color normal
echo ""
print_info "Repo: $REPO_DIR"

# Validate source files exist
for f in setup-omni-project.sh setup-omni-project.fish
    if not test -f "$REPO_DIR/scripts/$f"
        print_error "Missing: $REPO_DIR/scripts/$f"
        exit 1
    end
end

# Install scripts
mkdir -p "$DEST" "$BIN_DIR"
install -m 755 "$REPO_DIR/scripts/setup-omni-project.sh"  "$DEST/setup-omni-project.sh"
install -m 755 "$REPO_DIR/scripts/setup-omni-project.fish" "$DEST/setup-omni-project.fish"
print_success "Installed setup-omni-project.sh  -> $DEST/"
print_success "Installed setup-omni-project.fish -> $DEST/"

# Install schema (do not overwrite an existing customized copy)
set SCHEMA_SRC "$REPO_DIR/.omni/repo-registry.schema.json"
set SCHEMA_DST "$DEST/instructions/repo-registry.schema.json"
if test -f "$SCHEMA_SRC"
    if test -f "$SCHEMA_DST"
        print_info "Schema already exists, keeping: $SCHEMA_DST"
    else
        mkdir -p "$DEST/instructions"
        install -m 644 "$SCHEMA_SRC" "$SCHEMA_DST"
        print_success "Installed repo-registry.schema.json -> $DEST/instructions/"
    end
else
    print_warning "No schema found at $SCHEMA_SRC (skipped)"
end

# PATH entry points
ln -sfn "$DEST/setup-omni-project.sh"   "$BIN_DIR/setup-omni"
ln -sfn "$DEST/setup-omni-project.fish" "$BIN_DIR/setup-omni.fish"
print_success "Linked $BIN_DIR/setup-omni"
print_success "Linked $BIN_DIR/setup-omni.fish"

# PATH check
if contains -- "$BIN_DIR" $PATH
    print_success "\$HOME/.local/bin is on PATH"
else
    print_warning "\$HOME/.local/bin is NOT on PATH"
    echo "       Add to your shell profile:"
    echo "         bash/zsh:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "         fish:      fish_add_path \$HOME/.local/bin"
end

echo ""
print_success "Install complete!"
echo ""
echo "Usage (from any project directory):"
echo "  setup-omni            # bash/zsh"
echo "  setup-omni.fish       # fish"
echo ""
