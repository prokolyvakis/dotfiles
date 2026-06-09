-- AstroNvim bootstrap
-- Clones AstroNvim on first run, then loads it.
-- Requires: nvim >= 0.9

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^4",
    import = "astronvim.plugins",
    opts = {
      mapleader = " ",
      maplocalleader = ",",
      icons_enabled = true,
    },
  },
  { import = "community" },
} --[[@as LazySpec]], {
  install = { colorscheme = { "astrodark", "habamax" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "netrwPlugin", "tarPlugin", "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
