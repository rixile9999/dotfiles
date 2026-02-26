# lib/packages-linux.sh — Arch Linux package installation (pacman + AUR)

PACKAGES_FILE="$DOTFILES_DIR/packages.toml"

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
parse_packages() {
    local category=""
    while IFS= read -r line; do
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        [[ -z "$line" || "$line" == \#* ]] && continue

        if [[ "$line" =~ ^\[([a-zA-Z0-9_-]+)\]$ ]]; then
            category="${BASH_REMATCH[1]}"
            continue
        fi

        local pkg="${line%%[[:space:]]*}"
        pkg="${pkg%%#*}"
        [[ -n "$pkg" && -n "$category" ]] && printf '%s\t%s\n' "$category" "$pkg"
    done < "$PACKAGES_FILE"
}

# ── Check if package is in official repos ───────
is_official() {
    pacman -Si "$1" &>/dev/null
}

# ── Flush a category batch ──────────────────────
flush_category() {
    local category="$1"
    shift
    local sep="$1"
    shift

    [[ -z "$category" ]] && return

    # Split args into official and aur lists using separator
    local official=()
    local aur=()
    local target="official"
    for arg in "$@"; do
        if [[ "$arg" == "$sep" ]]; then
            target="aur"
            continue
        fi
        if [[ "$target" == "official" ]]; then
            official+=("$arg")
        else
            aur+=("$arg")
        fi
    done

    printf "\n${BOLD}── %s ──${RESET}\n" "$category"

    if (( ${#official[@]} > 0 )); then
        log "Official: ${official[*]}"
        if $DRY_RUN; then
            ok "(dry-run) Would install: ${official[*]}"
        else
            sudo pacman -S --needed --noconfirm "${official[@]}" || warn "Some packages in [$category] failed (official)"
        fi
    fi

    if (( ${#aur[@]} > 0 )); then
        log "AUR: ${aur[*]}"
        if $DRY_RUN; then
            ok "(dry-run) Would install via AUR: ${aur[*]}"
        elif [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --needed --noconfirm "${aur[@]}" || warn "Some packages in [$category] failed (AUR)"
        else
            warn "Skipping AUR packages (no helper): ${aur[*]}"
        fi
    fi
}

# ── Install packages by category ───────────────
install_packages() {
    local current_category=""
    local official_pkgs=()
    local aur_pkgs=()

    while IFS=$'\t' read -r category pkg; do
        if [[ "$category" != "$current_category" ]]; then
            if [[ -n "$current_category" ]]; then
                flush_category "$current_category" "__SEP__" "${official_pkgs[@]}" "__SEP__" "${aur_pkgs[@]}"
            fi
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
    if [[ -n "$current_category" ]]; then
        flush_category "$current_category" "__SEP__" "${official_pkgs[@]}" "__SEP__" "${aur_pkgs[@]}"
    fi
}
