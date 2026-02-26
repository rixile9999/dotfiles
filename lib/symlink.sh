# lib/symlink.sh — Symlink configs, local bin, and Claude Code configs

LINUX_ONLY_CONFIGS="foot kanshi niri"
LINUX_ONLY_BINS="niri-hotkeys"
MACOS_ONLY_HOME_DOTFILES=".zshrc"

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

# ── Symlink Claude Code configs ───────────────
symlink_claude() {
    printf "\n${BOLD}── Symlinking Claude Code configs ──${RESET}\n"

    local claude_dir="$DOTFILES_DIR/.claude"

    # CLAUDE.md -> ~/CLAUDE.md
    _symlink_file "$DOTFILES_DIR/CLAUDE.md" "$HOME/CLAUDE.md"

    # .claude/agents/*.md
    if [[ -d "$claude_dir/agents" ]]; then
        mkdir -p "$HOME/.claude/agents"
        for file in "$claude_dir"/agents/*.md; do
            [[ ! -f "$file" ]] && continue
            _symlink_file "$file" "$HOME/.claude/agents/$(basename "$file")"
        done
    fi

    # .claude/commands/*.md
    if [[ -d "$claude_dir/commands" ]]; then
        mkdir -p "$HOME/.claude/commands"
        for file in "$claude_dir"/commands/*.md; do
            [[ ! -f "$file" ]] && continue
            _symlink_file "$file" "$HOME/.claude/commands/$(basename "$file")"
        done
    fi

    # .claude/skills/*/SKILL.md
    if [[ -d "$claude_dir/skills" ]]; then
        for skill_dir in "$claude_dir"/skills/*/; do
            [[ ! -d "$skill_dir" ]] && continue
            local skill_name
            skill_name="$(basename "$skill_dir")"
            mkdir -p "$HOME/.claude/skills/$skill_name"
            for file in "$skill_dir"*; do
                [[ ! -f "$file" ]] && continue
                _symlink_file "$file" "$HOME/.claude/skills/$skill_name/$(basename "$file")"
            done
        done
    fi
}
