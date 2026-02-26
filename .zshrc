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

# ── nvm ────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
