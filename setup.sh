#!/usr/bin/env bash
set -euo pipefail

# ── Bootstrap ───────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

case "$PLATFORM" in
    linux) source "$SCRIPT_DIR/lib/packages-linux.sh" ;;
    macos) source "$SCRIPT_DIR/lib/packages-macos.sh" ;;
esac

source "$SCRIPT_DIR/lib/symlink.sh"
source "$SCRIPT_DIR/lib/neovim.sh"

# ── Main ────────────────────────────────────────
main() {
    printf "${BOLD}Dotfiles Setup${RESET} (%s)\n" "$PLATFORM"
    printf "Directory: %s\n" "$DOTFILES_DIR"
    $DRY_RUN && printf "${YELLOW}(DRY RUN — nothing will be installed)${RESET}\n"
    echo

    install_packages
    if ! $DRY_RUN; then
        symlink_configs
        symlink_home_dotfiles
        symlink_local_bin
        symlink_claude
        sync_neovim
    else
        printf "\n${BOLD}── Symlink targets ──${RESET}\n"
        for dir in "$DOTFILES_DIR/.config"/*/; do
            [[ -d "$dir" ]] || continue
            local cname
            cname="$(basename "$dir")"
            if [[ "$PLATFORM" == "macos" ]]; then
                local skip=false
                for lc in $LINUX_ONLY_CONFIGS; do
                    [[ "$cname" == "$lc" ]] && skip=true && break
                done
                if $skip; then
                    log "(dry-run) $cname: skipping (Linux-only)"
                    continue
                fi
            fi
            ok "(dry-run) Would symlink: $cname"
        done
        printf "\n${BOLD}── Home dotfile targets ──${RESET}\n"
        for dotfile in $MACOS_ONLY_HOME_DOTFILES; do
            [[ ! -f "$DOTFILES_DIR/$dotfile" ]] && continue
            if [[ "$PLATFORM" == "macos" ]]; then
                ok "(dry-run) Would symlink: $dotfile → ~/$dotfile"
            else
                log "(dry-run) $dotfile: skipping (macOS-only)"
            fi
        done
        printf "\n${BOLD}── Local bin targets ──${RESET}\n"
        for file in "$DOTFILES_DIR/.local/bin"/*; do
            [[ -f "$file" ]] || continue
            local bname
            bname="$(basename "$file")"
            if [[ "$PLATFORM" == "macos" ]]; then
                local skip=false
                for lb in $LINUX_ONLY_BINS; do
                    [[ "$bname" == "$lb" ]] && skip=true && break
                done
                if $skip; then
                    log "(dry-run) $bname: skipping (Linux-only)"
                    continue
                fi
            fi
            ok "(dry-run) Would symlink: $bname → ~/.local/bin/"
        done
        printf "\n${BOLD}── Claude Code targets ──${RESET}\n"
        ok "(dry-run) Would symlink: CLAUDE.md → ~/CLAUDE.md"
        for file in "$DOTFILES_DIR/.claude"/agents/*.md "$DOTFILES_DIR/.claude"/commands/*.md; do
            [[ -f "$file" ]] && ok "(dry-run) Would symlink: $(basename "$file") → ~/.claude/..."
        done
        for skill_dir in "$DOTFILES_DIR/.claude"/skills/*/; do
            [[ -d "$skill_dir" ]] && ok "(dry-run) Would symlink skill: $(basename "$skill_dir") → ~/.claude/skills/"
        done
        sync_neovim
    fi

    printf "\n${GREEN}${BOLD}Done!${RESET}\n"
}

main
