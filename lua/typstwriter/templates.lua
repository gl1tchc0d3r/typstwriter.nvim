--- Template discovery and management for typstwriter.nvim
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local M = {}

--- Get available templates from template directory
--- @return table<string, table> Map of template name to template info
function M.get_available_templates()
  local templates = {}
  local template_dir = config.get("template_dir")

  if not utils.dir_exists(template_dir) then
    utils.notify("Template directory does not exist: " .. template_dir, vim.log.levels.WARN)
    return templates
  end

  local template_files = vim.fn.glob(template_dir .. "/*.typ", false, true)

  for _, filepath in ipairs(template_files) do
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local basename = vim.fn.fnamemodify(filepath, ":t:r")

    -- Skip base.typ as it's not a template for direct use
    if basename ~= "base" then
      -- Capitalize first letter for display
      local display_name = utils.capitalize(basename)

      templates[basename] = {
        file = filename,
        path = filepath,
        display_name = display_name,
        description = display_name .. " template",
      }
    end
  end

  return templates
end

--- Create a new document from template
--- @param template_name string Name of template to use
--- @param doc_name string Name for the new document
function M.create_document(template_name, doc_name)
  local templates = M.get_available_templates()
  local template = templates[template_name]

  if not template then
    utils.notify("Template not found: " .. template_name, vim.log.levels.ERROR)
    return false
  end

  -- Generate filename
  local filename = utils.format_filename(doc_name)
  local notes_dir = config.get("notes_dir")
  local filepath = notes_dir .. "/" .. filename

  -- Check if file already exists
  if utils.file_exists(filepath) then
    local confirm = vim.fn.confirm("File " .. filename .. " already exists. Overwrite?", "&Yes\n&No", 2)
    if confirm ~= 1 then
      utils.notify("File creation cancelled", vim.log.levels.WARN)
      return false
    end
  end

  -- Check template file exists
  local template_path = template.path
  if not utils.file_exists(template_path) then
    utils.notify("Template file not found: " .. template_path, vim.log.levels.ERROR)
    return false
  end

  -- Copy template to new file
  local copy_cmd = string.format('cp "%s" "%s"', template_path, filepath)
  local success = utils.system_exec(copy_cmd, "✓ Created: " .. filename, "✗ Failed to create file")

  if success then
    -- Open the new file
    vim.cmd("edit " .. filepath)

    -- Auto-compile if enabled
    if config.get("auto_compile") then
      vim.defer_fn(function()
        require("typstwriter.compiler").compile_current()
      end, 500)
    end
  end

  return success
end

--- Interactive template selection and document creation
function M.create_from_template()
  -- Check if typst is available
  if not utils.has_typst() then
    utils.notify("Typst binary not found in PATH. Please install Typst.", vim.log.levels.ERROR)
    return
  end

  -- Get available templates
  local templates = M.get_available_templates()

  -- Check if we have any templates
  if next(templates) == nil then
    utils.notify("No templates found in " .. config.get("template_dir"), vim.log.levels.WARN)
    return
  end

  -- Prepare template selection
  local template_names = {}
  local template_descriptions = {}

  for name, template in pairs(templates) do
    table.insert(template_names, name)
    table.insert(template_descriptions, name .. ": " .. template.description)
  end

  -- Show template selection
  utils.select(template_descriptions, {
    prompt = "Select template:",
  }, function(choice)
    if not choice then
      return
    end

    -- Extract template name from choice
    local template_name = choice:match("^([^:]+):")
    if not template_name then
      return
    end

    -- Get document name
    utils.input({
      prompt = "Document name: ",
      default = template_name,
    }, function(doc_name)
      if not doc_name or doc_name == "" then
        return
      end

      M.create_document(template_name, doc_name)
    end)
  end)
end

--- List available templates
--- @return table List of template info for display
function M.list_templates()
  local templates = M.get_available_templates()
  local list = {}

  for name, template in pairs(templates) do
    table.insert(list, {
      name = name,
      display_name = template.display_name,
      description = template.description,
      path = template.path,
    })
  end

  -- Sort by name
  table.sort(list, function(a, b)
    return a.name < b.name
  end)

  return list
end

--- Print available templates to command line
function M.show_templates()
  local templates = M.list_templates()

  if #templates == 0 then
    print("No templates found in " .. config.get("template_dir"))
    return
  end

  print("Available templates:")
  print("==================")
  for _, template in ipairs(templates) do
    print(string.format("  %-15s %s", template.name, template.description))
  end
  print("")
  print("Template directory: " .. config.get("template_dir"))
end

return M
