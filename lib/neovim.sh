# lib/neovim.sh — Neovim plugin sync

sync_neovim() {
    printf "\n${BOLD}── Neovim plugin sync ──${RESET}\n"

    if ! command -v nvim &>/dev/null; then
        warn "Neovim not found, skipping plugin sync."
        return
    fi

    if [[ ! -d "$DOTFILES_DIR/.config/nvim" ]]; then
        warn "No nvim config in dotfiles, skipping plugin sync."
        return
    fi

    log "Syncing Neovim plugins (Lazy.nvim)..."
    if $DRY_RUN; then
        ok "(dry-run) Would run: nvim --headless \"+Lazy! sync\" +qa"
    else
        nvim --headless "+Lazy! sync" +qa 2>&1 || warn "Neovim plugin sync had issues"
        ok "Neovim plugins synced."
    fi
}
