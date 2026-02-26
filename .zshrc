# ── Homebrew ────────────────────────────────────
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# ── Pure prompt ─────────────────────────────────
fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
autoload -U promptinit
promptinit
prompt pure

# ── Plugins ─────────────────────────────────────
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
