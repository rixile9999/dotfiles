-- Set leader key to Space (must be set before plugins load)
vim.g.mapleader = " "
-- Disable netrw (recommended by nvim-tree, must be set before plugins load)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- Color column rulers
vim.opt.colorcolumn = "80,100,120"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require("lazy").setup("plugins")
