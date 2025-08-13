--- Main module for typstwriter.nvim
--- A complete Typst writing system for Neovim
local M = {}

-- Module dependencies
local compiler = require("typstwriter.compiler")
local config = require("typstwriter.config")
local templates = require("typstwriter.templates")
local utils = require("typstwriter.utils")

--- Setup the plugin with user configuration
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  -- Initialize configuration
  config.setup(user_config)

  -- Create user commands
  M.create_commands()

  -- Setup key mappings if enabled
  M.setup_keymaps()

  -- Setup autocommands
  M.setup_autocommands()

  -- Check system requirements
  M.check_requirements()
end

--- Create user commands
function M.create_commands()
  vim.api.nvim_create_user_command("TWriterNew", function()
    templates.create_from_template()
  end, {
    desc = "Create new document from template",
  })

  vim.api.nvim_create_user_command("TWriterCompile", function()
    compiler.compile_current()
  end, {
    desc = "Compile current document to PDF",
  })

  vim.api.nvim_create_user_command("TWriterOpen", function()
    compiler.open_pdf()
  end, {
    desc = "Open PDF of current document",
  })

  vim.api.nvim_create_user_command("TWriterBoth", function()
    compiler.compile_and_open()
  end, {
    desc = "Compile current document and open PDF",
  })

  -- Additional utility commands
  vim.api.nvim_create_user_command("TWriterStatus", function()
    compiler.show_status()
  end, {
    desc = "Show compilation status and system info",
  })

  vim.api.nvim_create_user_command("TWriterTemplates", function()
    templates.show_templates()
  end, {
    desc = "List available document templates",
  })
end

--- Setup key mappings based on configuration
function M.setup_keymaps()
  local keymaps = config.get("keymaps")
  if not keymaps then
    return
  end

  -- Global keymap for creating new documents (works from any buffer)
  if keymaps.new_document then
    vim.keymap.set("n", keymaps.new_document, function()
      templates.create_from_template()
    end, {
      noremap = true,
      silent = true,
      desc = "Create new Typst document from template",
    })
  end

  -- Buffer-specific keymaps for Typst files
  local function setup_buffer_keymaps()
    local opts = { buffer = true, silent = true }

    if keymaps.compile then
      vim.keymap.set(
        "n",
        keymaps.compile,
        compiler.compile_current,
        vim.tbl_extend("force", opts, { desc = "Compile Typst to PDF" })
      )
    end

    if keymaps.open_pdf then
      vim.keymap.set(
        "n",
        keymaps.open_pdf,
        compiler.open_pdf,
        vim.tbl_extend("force", opts, { desc = "Open Typst PDF" })
      )
    end

    if keymaps.compile_and_open then
      vim.keymap.set(
        "n",
        keymaps.compile_and_open,
        compiler.compile_and_open,
        vim.tbl_extend("force", opts, { desc = "Compile and open Typst PDF" })
      )
    end

    -- Alternative short mappings
    if keymaps.pdf_generate then
      vim.keymap.set(
        "n",
        keymaps.pdf_generate,
        compiler.compile_current,
        vim.tbl_extend("force", opts, { desc = "Generate PDF from Typst" })
      )
    end

    if keymaps.pdf_open then
      vim.keymap.set(
        "n",
        keymaps.pdf_open,
        compiler.open_pdf,
        vim.tbl_extend("force", opts, { desc = "Open Typst PDF" })
      )
    end
  end

  -- Auto commands for Typst files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = setup_buffer_keymaps,
    desc = "Setup Typst-specific keymaps",
  })
end

--- Setup autocommands
function M.setup_autocommands()
  local augroup = vim.api.nvim_create_augroup("TWriter", { clear = true })

  -- Setup auto-compile for new Typst files if enabled
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "typst",
    callback = function()
      local file_path = vim.fn.expand("%:p")
      if config.get("auto_compile") then
        compiler.setup_auto_compile(file_path)
      end
    end,
    desc = "Setup auto-compile for Typst files",
  })
end

--- Check system requirements and warn if missing
function M.check_requirements()
  if not utils.has_typst() then
    utils.notify("Typst binary not found in PATH. Install from: https://github.com/typst/typst", vim.log.levels.WARN)
  end

  if not utils.get_pdf_opener() then
    utils.notify("No PDF opener detected. PDF opening may not work.", vim.log.levels.WARN)
  end

  -- Check directories
  local notes_dir = config.get("notes_dir")
  local template_dir = config.get("template_dir")

  if not utils.dir_exists(notes_dir) then
    utils.notify("Notes directory created: " .. notes_dir)
  end

  if not utils.dir_exists(template_dir) then
    utils.notify("Template directory created: " .. template_dir)
  end
end

--- Get plugin information
--- @return table Plugin info
function M.info()
  return {
    name = "typstwriter.nvim",
    version = "1.0.0",
    description = "A complete Typst writing system for Neovim",
    author = "gl1tchc0d3r",
    config = config.current,
    requirements = {
      neovim = ">=0.7.0",
      typst = utils.has_typst(),
      pdf_opener = utils.get_pdf_opener() ~= nil,
    },
  }
end

--- Integration with which-key.nvim (if available)
local function setup_which_key()
  local has_which_key, wk = pcall(require, "which-key")
  if not has_which_key then
    return
  end

  local keymaps = config.get("keymaps")
  if not keymaps then
    return
  end

  -- Register key descriptions (only for actual keymaps, not conflicting groups)
  local registrations = {}

  if keymaps.new_document then
    table.insert(registrations, { keymaps.new_document, desc = "New from template", mode = "n" })
  end

  if keymaps.compile then
    table.insert(registrations, { keymaps.compile, desc = "PDF compile", mode = "n" })
  end

  if keymaps.open_pdf then
    table.insert(registrations, { keymaps.open_pdf, desc = "PDF open", mode = "n" })
  end

  if keymaps.compile_and_open then
    table.insert(registrations, { keymaps.compile_and_open, desc = "PDF compile & open", mode = "n" })
  end

  if #registrations > 0 then
    wk.add(registrations)
  end
end

-- Auto-setup which-key integration when plugin is loaded
vim.defer_fn(setup_which_key, 100)

-- Export public API
M.templates = templates
M.compiler = compiler
M.config = config
M.utils = utils

return M
