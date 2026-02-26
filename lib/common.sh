# lib/common.sh — Colors, logging, helpers, OS detection

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
PLATFORM=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --linux)   PLATFORM="linux" ;;
        --macos)  PLATFORM="macos" ;;
        --help|-h)
            echo "Usage: $0 --linux|--macos [--dry-run]"
            echo "  --linux    Target Linux (Arch, pacman)"
            echo "  --macos   Target macOS (Homebrew)"
            echo "  --dry-run  Show what would be done without making changes"
            exit 0
            ;;
        *) err "Unknown option: $arg"; exit 1 ;;
    esac
done

if [[ -z "$PLATFORM" ]]; then
    err "Platform required. Use --linux or --macos."
    echo "Usage: $0 --linux|--macos [--dry-run]"
    exit 1
fi

# ── Shared helper ───────────────────────────────
_symlink_file() {
    local source="$1"
    local target="$2"
    local name
    name="$(basename "$target")"

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
        warn "$name: backing up existing file to $backup"
        mv "$target" "$backup"
        ln -sf "$source" "$target"
        ok "$name: symlinked (old file backed up)"
    else
        ln -sf "$source" "$target"
        ok "$name: symlinked"
    fi
}
