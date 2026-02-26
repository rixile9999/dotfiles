# lib/packages-macos.sh — macOS package installation (Homebrew)

PACKAGES_FILE="$DOTFILES_DIR/packages-macos.toml"

# ── Detect Homebrew ─────────────────────────────
if ! command -v brew &>/dev/null; then
    err "Homebrew not found. Install it from https://brew.sh"
    exit 1
fi

# ── Parse packages-macos.toml ──────────────────
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

# ── Install packages by category ───────────────
install_packages() {
    local current_category=""
    local pkgs=()

    while IFS=$'\t' read -r category pkg; do
        if [[ "$category" != "$current_category" ]]; then
            if [[ -n "$current_category" ]]; then
                flush_category "$current_category" "${pkgs[@]}"
            fi
            current_category="$category"
            pkgs=()
        fi
        pkgs+=("$pkg")
    done < <(parse_packages)

    # Flush the last category
    if [[ -n "$current_category" ]]; then
        flush_category "$current_category" "${pkgs[@]}"
    fi
}

flush_category() {
    local category="$1"
    shift
    local pkgs=("$@")

    [[ -z "$category" ]] && return
    (( ${#pkgs[@]} == 0 )) && return

    printf "\n${BOLD}── %s ──${RESET}\n" "$category"
    log "Packages: ${pkgs[*]}"

    if $DRY_RUN; then
        if [[ "$category" == "casks" ]]; then
            ok "(dry-run) Would install casks: ${pkgs[*]}"
        else
            ok "(dry-run) Would install: ${pkgs[*]}"
        fi
        return
    fi

    if [[ "$category" == "casks" ]]; then
        brew install --cask "${pkgs[@]}" || warn "Some casks in [$category] failed"
    else
        brew install "${pkgs[@]}" || warn "Some packages in [$category] failed"
    fi
}
