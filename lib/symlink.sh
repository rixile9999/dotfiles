# lib/symlink.sh — Symlink configs, local bin, and Claude Code configs

LINUX_ONLY_CONFIGS="foot kanshi niri"
LINUX_ONLY_BINS="niri-hotkeys"
MACOS_ONLY_HOME_DOTFILES=".zshrc .wezterm.lua"

# ── Symlink configs ────────────────────────────
symlink_configs() {
    printf "\n${BOLD}── Symlinking configs ──${RESET}\n"

    local configs_dir="$DOTFILES_DIR/.config"
    [[ ! -d "$configs_dir" ]] && { warn "No .config directory in dotfiles, skipping symlinks."; return; }

    for dir in "$configs_dir"/*/; do
        local name
        name="$(basename "$dir")"
        local source="${dir%/}"
        local target="$HOME/.config/$name"

        # Skip Linux-only configs on macOS
        if [[ "$PLATFORM" == "macos" ]]; then
            local skip=false
            for lc in $LINUX_ONLY_CONFIGS; do
                [[ "$name" == "$lc" ]] && skip=true && break
            done
            if $skip; then
                log "$name: skipping (Linux-only)"
                continue
            fi
        fi

        _symlink_file "$source" "$target"
    done
}

# ── Symlink local bin scripts ──────────────────
symlink_local_bin() {
    printf "\n${BOLD}── Symlinking local bin scripts ──${RESET}\n"

    local bin_dir="$DOTFILES_DIR/.local/bin"
    [[ ! -d "$bin_dir" ]] && { warn "No .local/bin directory in dotfiles, skipping."; return; }

    mkdir -p "$HOME/.local/bin"

    for file in "$bin_dir"/*; do
        [[ ! -f "$file" ]] && continue
        local name
        name="$(basename "$file")"
        local target="$HOME/.local/bin/$name"

        # Skip Linux-only bins on macOS
        if [[ "$PLATFORM" == "macos" ]]; then
            local skip=false
            for lb in $LINUX_ONLY_BINS; do
                [[ "$name" == "$lb" ]] && skip=true && break
            done
            if $skip; then
                log "$name: skipping (Linux-only)"
                continue
            fi
        fi

        _symlink_file "$file" "$target"
    done
}

# ── Symlink home dotfiles ─────────────────────
symlink_home_dotfiles() {
    printf "\n${BOLD}── Symlinking home dotfiles ──${RESET}\n"

    for dotfile in $MACOS_ONLY_HOME_DOTFILES; do
        local source="$DOTFILES_DIR/$dotfile"
        [[ ! -f "$source" ]] && continue

        if [[ "$PLATFORM" != "macos" ]]; then
            log "$dotfile: skipping (macOS-only)"
            continue
        fi

        _symlink_file "$source" "$HOME/$dotfile"
    done
}
