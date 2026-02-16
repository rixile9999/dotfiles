#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.toml"
DRY_RUN=false

# ── Colors ──────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

log()   { printf "${BLUE}::${RESET} %s\n" "$*"; }
ok()    { printf "${GREEN}::${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}:: %s${RESET}\n" "$*"; }
err()   { printf "${RED}:: %s${RESET}\n" "$*" >&2; }

# ── Parse args ──────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --help|-h)
            echo "Usage: $0 [--dry-run]"
            echo "  --dry-run  Parse packages and show what would be installed"
            exit 0
            ;;
        *) err "Unknown option: $arg"; exit 1 ;;
    esac
done

# ── Detect package manager ──────────────────────
if ! command -v pacman &>/dev/null; then
    err "pacman not found. This script is for Arch-based systems."
    exit 1
fi

AUR_HELPER=""
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
fi

if [[ -z "$AUR_HELPER" ]]; then
    warn "No AUR helper found (paru/yay). AUR packages will be skipped."
else
    log "AUR helper: $AUR_HELPER"
fi

# ── Parse packages.toml ────────────────────────
# Returns lines of "category<TAB>package"
parse_packages() {
    local category=""
    while IFS= read -r line; do
        # Strip leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Skip empty lines and comment-only lines
        [[ -z "$line" || "$line" == \#* ]] && continue

        # Section header
        if [[ "$line" =~ ^\[([a-zA-Z0-9_-]+)\]$ ]]; then
            category="${BASH_REMATCH[1]}"
            continue
        fi

        # Package line: take first word (before comment)
        local pkg="${line%%[[:space:]]*}"
        pkg="${pkg%%#*}"
        [[ -n "$pkg" && -n "$category" ]] && printf '%s\t%s\n' "$category" "$pkg"
    done < "$PACKAGES_FILE"
}

# ── Check if package is in official repos ───────
is_official() {
    pacman -Si "$1" &>/dev/null
}

# ── Install packages by category ───────────────
install_packages() {
    local current_category=""
    local official_pkgs=()
    local aur_pkgs=()

    while IFS=$'\t' read -r category pkg; do
        # When category changes, flush the previous batch
        if [[ "$category" != "$current_category" ]]; then
            flush_category "$current_category" official_pkgs aur_pkgs
            current_category="$category"
            official_pkgs=()
            aur_pkgs=()
        fi

        if is_official "$pkg"; then
            official_pkgs+=("$pkg")
        else
            aur_pkgs+=("$pkg")
        fi
    done < <(parse_packages)

    # Flush the last category
    flush_category "$current_category" official_pkgs aur_pkgs
}

flush_category() {
    local category="$1"
    local -n _official="$2"
    local -n _aur="$3"

    [[ -z "$category" ]] && return

    printf "\n${BOLD}── %s ──${RESET}\n" "$category"

    if (( ${#_official[@]} > 0 )); then
        log "Official: ${_official[*]}"
        if $DRY_RUN; then
            ok "(dry-run) Would install: ${_official[*]}"
        else
            sudo pacman -S --needed --noconfirm "${_official[@]}" || warn "Some packages in [$category] failed (official)"
        fi
    fi

    if (( ${#_aur[@]} > 0 )); then
        log "AUR: ${_aur[*]}"
        if $DRY_RUN; then
            ok "(dry-run) Would install via AUR: ${_aur[*]}"
        elif [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --needed --noconfirm "${_aur[@]}" || warn "Some packages in [$category] failed (AUR)"
        else
            warn "Skipping AUR packages (no helper): ${_aur[*]}"
        fi
    fi
}

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

        if [[ -L "$target" ]]; then
            local current
            current="$(readlink -f "$target")"
            if [[ "$current" == "$(readlink -f "$source")" ]]; then
                log "$name: symlink already exists"
            else
                warn "$name: updating symlink (was pointing to $current)"
                ln -snf "$source" "$target"
                ok "$name: symlink updated"
            fi
        elif [[ -e "$target" ]]; then
            local backup="$target.bak.$(date +%Y%m%d%H%M%S)"
            warn "$name: backing up existing config to $backup"
            mv "$target" "$backup"
            ln -sf "$source" "$target"
            ok "$name: symlinked (old config backed up)"
        else
            mkdir -p "$HOME/.config"
            ln -sf "$source" "$target"
            ok "$name: symlinked"
        fi
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

        if [[ -L "$target" ]]; then
            local current
            current="$(readlink -f "$target")"
            if [[ "$current" == "$(readlink -f "$file")" ]]; then
                log "$name: symlink already exists"
            else
                warn "$name: updating symlink (was pointing to $current)"
                ln -snf "$file" "$target"
                ok "$name: symlink updated"
            fi
        elif [[ -e "$target" ]]; then
            local backup="$target.bak.$(date +%Y%m%d%H%M%S)"
            warn "$name: backing up existing file to $backup"
            mv "$target" "$backup"
            ln -sf "$file" "$target"
            ok "$name: symlinked (old file backed up)"
        else
            ln -sf "$file" "$target"
            ok "$name: symlinked"
        fi
    done
}

# ── Neovim plugin sync ─────────────────────────
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

# ── Main ────────────────────────────────────────
main() {
    printf "${BOLD}Dotfiles Setup${RESET}\n"
    printf "Directory: %s\n" "$DOTFILES_DIR"
    $DRY_RUN && printf "${YELLOW}(DRY RUN — nothing will be installed)${RESET}\n"
    echo

    install_packages
    if ! $DRY_RUN; then
        symlink_configs
        symlink_local_bin
        sync_neovim
    else
        printf "\n${BOLD}── Symlink targets ──${RESET}\n"
        for dir in "$DOTFILES_DIR/.config"/*/; do
            [[ -d "$dir" ]] && ok "(dry-run) Would symlink: $(basename "$dir")"
        done
        printf "\n${BOLD}── Local bin targets ──${RESET}\n"
        for file in "$DOTFILES_DIR/.local/bin"/*; do
            [[ -f "$file" ]] && ok "(dry-run) Would symlink: $(basename "$file") → ~/.local/bin/"
        done
        sync_neovim
    fi

    printf "\n${GREEN}${BOLD}Done!${RESET}\n"
}

main
