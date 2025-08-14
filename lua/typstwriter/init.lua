--- Main plugin entry point for typstwriter.nvim
--- Metadata-driven Typst writing system
local M = {}

-- Module dependencies
local metadata = require("typstwriter.metadata")
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local templates = require("typstwriter.templates")
local compiler = require("typstwriter.compiler")

--- Setup the plugin system
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  -- Initialize configuration
  config.setup(user_config)

  -- Create commands
  M.create_commands()

  -- Setup key mappings
  M.setup_keymaps()

  -- Check system requirements
  M.check_requirements()

  utils.notify("TypstWriter initialized")
end

--- Create user commands
function M.create_commands()
  vim.api.nvim_create_user_command("TypstWriterNew", function()
    templates.create_from_template()
  end, {
    desc = "Create new document from template",
  })

  vim.api.nvim_create_user_command("TypstWriterCompile", function()
    compiler.compile_current()
  end, {
    desc = "Compile current document to PDF",
  })

  vim.api.nvim_create_user_command("TypstWriterOpen", function()
    compiler.open_pdf()
  end, {
    desc = "Open PDF of current document",
  })

  vim.api.nvim_create_user_command("TypstWriterBoth", function()
    compiler.compile_and_open()
  end, {
    desc = "Compile and open PDF",
  })

  vim.api.nvim_create_user_command("TypstWriterStatus", function()
    compiler.show_status()
  end, {
    desc = "Show system status and metadata info",
  })

  vim.api.nvim_create_user_command("TypstWriterTemplates", function()
    templates.show_templates()
  end, {
    desc = "List available templates",
  })
end

--- Setup key mappings
function M.setup_keymaps()
  local keymaps = config.get("keymaps")
  if not keymaps then
    return
  end

  -- Global keymap for creating new documents
  if keymaps.new_document then
    vim.keymap.set("n", keymaps.new_document, function()
      templates.create_from_template()
    end, {
      noremap = true,
      silent = true,
      desc = "Create new Typst document",
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
        vim.tbl_extend("force", opts, { desc = "Compile and open PDF" })
      )
    end
  end

  -- Setup buffer keymaps for Typst files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = setup_buffer_keymaps,
    desc = "Setup Typst-specific keymaps",
  })
end

--- Check system requirements
function M.check_requirements()
  if not utils.has_typst() then
    utils.notify("Typst binary not found. Install from: https://typst.app", vim.log.levels.WARN)
  end

  if not utils.get_pdf_opener() then
    utils.notify("No PDF opener detected. PDF opening may not work.", vim.log.levels.WARN)
  end

  -- Ensure directories exist
  config.ensure_directories()
end

--- Get plugin information
--- @return table Plugin info
function M.info()
  return {
    name = "typstwriter.nvim",
    version = "2.0.0-dev",
    description = "Metadata-driven Typst writing system",
    approach = "Native Typst metadata + query system",
    config = config.current,
    requirements = {
      neovim = ">=0.7.0",
      typst = utils.has_typst(),
      pdf_opener = utils.get_pdf_opener() ~= nil,
    },
  }
end

--- Test functionality
function M.test()
  print("Testing TypstWriter functionality")
  print("===================================")

  -- Test configuration
  print("Configuration:")
  print("  Notes dir: " .. config.get("notes_dir"))
  print("  Template dir: " .. config.get("template_dir"))
  print("")

  -- Test template discovery
  print("Templates:")
  local templates = templates.get_available_templates()
  for name, template in pairs(templates) do
    print("  " .. name .. ": " .. template.description)
  end
  print("")

  -- Test metadata extraction
  print("Metadata test:")
  for name, template in pairs(templates) do
    local meta = metadata.parse_metadata(template.path)
    if meta then
      print("  ✓ " .. name .. " has valid metadata")
    else
      print("  ✗ " .. name .. " missing metadata")
    end
  end

  print("")
  print("✅ system functional!")
end

-- Export public API
M.templates = templates
M.compiler = compiler
M.config = config
M.utils = utils

return M
