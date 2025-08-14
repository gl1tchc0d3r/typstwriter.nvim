--- New plugin entry point for typstwriter.nvim v2
--- Clean, metadata-driven implementation
local M = {}

-- Module dependencies
local metadata = require("typstwriter.metadata")
local v2_config = require("typstwriter.v2_config")
local v2_utils = require("typstwriter.v2_utils")
local v2_templates = require("typstwriter.v2_templates")
local v2_compiler = require("typstwriter.v2_compiler")

--- Setup the v2 plugin system
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  -- Initialize v2 configuration
  v2_config.setup(user_config)

  -- Create v2 commands
  M.create_commands()

  -- Setup v2 key mappings
  M.setup_keymaps()

  -- Check system requirements
  M.check_requirements()

  v2_utils.notify("TypstWriter v2 initialized")
end

--- Create v2 user commands
function M.create_commands()
  vim.api.nvim_create_user_command("TypstWriterNew", function()
    v2_templates.create_from_template()
  end, {
    desc = "Create new document from v2 template",
  })

  vim.api.nvim_create_user_command("TypstWriterCompile", function()
    v2_compiler.compile_current()
  end, {
    desc = "Compile current document to PDF (v2)",
  })

  vim.api.nvim_create_user_command("TypstWriterOpen", function()
    v2_compiler.open_pdf()
  end, {
    desc = "Open PDF of current document (v2)",
  })

  vim.api.nvim_create_user_command("TypstWriterBoth", function()
    v2_compiler.compile_and_open()
  end, {
    desc = "Compile and open PDF (v2)",
  })

  vim.api.nvim_create_user_command("TypstWriterStatus", function()
    v2_compiler.show_status()
  end, {
    desc = "Show v2 system status and metadata info",
  })

  vim.api.nvim_create_user_command("TypstWriterTemplates", function()
    v2_templates.show_templates()
  end, {
    desc = "List available v2 templates",
  })
end

--- Setup v2 key mappings
function M.setup_keymaps()
  local keymaps = v2_config.get("keymaps")
  if not keymaps then
    return
  end

  -- Global keymap for creating new documents
  if keymaps.new_document then
    vim.keymap.set("n", keymaps.new_document, function()
      v2_templates.create_from_template()
    end, {
      noremap = true,
      silent = true,
      desc = "Create new Typst document (v2)",
    })
  end

  -- Buffer-specific keymaps for Typst files
  local function setup_buffer_keymaps()
    local opts = { buffer = true, silent = true }

    if keymaps.compile then
      vim.keymap.set(
        "n",
        keymaps.compile,
        v2_compiler.compile_current,
        vim.tbl_extend("force", opts, { desc = "Compile Typst to PDF (v2)" })
      )
    end

    if keymaps.open_pdf then
      vim.keymap.set(
        "n",
        keymaps.open_pdf,
        v2_compiler.open_pdf,
        vim.tbl_extend("force", opts, { desc = "Open Typst PDF (v2)" })
      )
    end

    if keymaps.compile_and_open then
      vim.keymap.set(
        "n",
        keymaps.compile_and_open,
        v2_compiler.compile_and_open,
        vim.tbl_extend("force", opts, { desc = "Compile and open PDF (v2)" })
      )
    end
  end

  -- Setup buffer keymaps for Typst files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = setup_buffer_keymaps,
    desc = "Setup v2 Typst-specific keymaps",
  })
end

--- Check system requirements for v2
function M.check_requirements()
  if not v2_utils.has_typst() then
    v2_utils.notify("Typst binary not found. Install from: https://typst.app", vim.log.levels.WARN)
  end

  if not v2_utils.get_pdf_opener() then
    v2_utils.notify("No PDF opener detected. PDF opening may not work.", vim.log.levels.WARN)
  end

  -- Ensure directories exist
  v2_config.ensure_directories()
end

--- Get v2 plugin information
--- @return table Plugin info
function M.info()
  return {
    name = "typstwriter.nvim v2",
    version = "2.0.0-dev",
    description = "Metadata-driven Typst writing system",
    approach = "Native Typst metadata + query system",
    config = v2_config.current,
    requirements = {
      neovim = ">=0.7.0",
      typst = v2_utils.has_typst(),
      pdf_opener = v2_utils.get_pdf_opener() ~= nil,
    },
  }
end

--- Test v2 functionality
function M.test()
  print("Testing TypstWriter v2 functionality")
  print("===================================")

  -- Test configuration
  print("Configuration:")
  print("  Notes dir: " .. v2_config.get("notes_dir"))
  print("  Template dir: " .. v2_config.get("template_dir"))
  print("")

  -- Test template discovery
  print("Templates:")
  local templates = v2_templates.get_available_templates()
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
  print("✅ v2 system functional!")
end

-- Export public API
M.templates = v2_templates
M.compiler = v2_compiler
M.config = v2_config
M.utils = v2_utils

return M
