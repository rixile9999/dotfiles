# dotfiles

Linux environment configuration files.

## Contents

- **niri** — Niri Wayland compositor config
- **neovim** — Neovim editor config

## Quick Start

```bash
git clone git@github.com:rixile9999/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup.sh
```

## Setup Script

`setup.sh` bootstraps a fresh Arch-based machine:

1. Installs packages from `packages.toml` (official repos + AUR)
2. Symlinks configs from `.config/` to `~/.config/`
3. Syncs Neovim plugins via Lazy.nvim

### Dry Run

Preview what would be installed without making changes:

```bash
bash setup.sh --dry-run
```

### Package List

Packages are defined in `packages.toml`, organized by category with inline comments. Edit the file to add or remove packages before running setup.

## Manual Symlinks

If you prefer to symlink individually:

```bash
ln -sf ~/dotfiles/.config/niri ~/.config/niri
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
```
