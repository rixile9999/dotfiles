return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nightfox").setup({
      options = {
        transparent = true, -- keep foot's transparent background
      },
    })
    vim.cmd("colorscheme nightfox")
  end,
}
