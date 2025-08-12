--- Plugin entry point for typstwriter.nvim
--- This file is automatically loaded by Neovim plugin managers

-- Prevent loading twice
if vim.g.typstwriter_loaded then
  return
end
vim.g.typstwriter_loaded = 1

-- Check Neovim version requirement
if vim.fn.has("nvim-0.7.0") == 0 then
  vim.notify("typstwriter.nvim requires Neovim 0.7.0 or later", vim.log.levels.ERROR)
  return
end

-- The plugin will be initialized when the user calls setup()
-- This allows for configuration before initialization
