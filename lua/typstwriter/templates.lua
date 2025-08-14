--- Metadata-driven template system for typstwriter.nvim
local metadata = require("typstwriter.metadata")
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local M = {}

--- Get available templates
--- @return table Map of template name to template info
function M.get_available_templates()
  local templates = {}
  local template_dir = config.get("template_dir")

  local template_files = vim.fn.glob(template_dir .. "/*.typ", false, true)

  if #template_files == 0 then
    -- No templates found, which could mean directory doesn't exist or is empty
    return templates
  end

  for _, filepath in ipairs(template_files) do
    local basename = vim.fn.fnamemodify(filepath, ":t:r")

    -- Skip base templates
    if basename ~= "base" and basename ~= "base-simple" then
      local template_info = M.get_template_info(filepath)
      if template_info then
        templates[basename] = template_info
      end
    end
  end

  return templates
end

--- Get template information using metadata
--- @param filepath string Path to template file
--- @return table|nil Template information or nil if invalid
function M.get_template_info(filepath)
  local basename = vim.fn.fnamemodify(filepath, ":t:r")
  local meta = metadata.parse_metadata(filepath)

  if not meta then
    -- Fallback for templates without metadata
    return {
      name = basename,
      title = utils.capitalize(basename),
      type = "document",
      description = utils.capitalize(basename) .. " template",
      path = filepath,
      has_metadata = false,
    }
  end

  -- Validate template metadata
  local valid, error_msg = config.validate_metadata(meta)
  if not valid then
    utils.notify("Invalid template " .. basename .. ": " .. error_msg, vim.log.levels.WARN)
    return nil
  end

  return {
    name = basename,
    title = meta.title or utils.capitalize(basename),
    type = meta.type or "document",
    description = meta.description or (meta.title .. " template"),
    path = filepath,
    metadata = meta,
    has_metadata = true,
  }
end

--- Create new document from template with metadata
--- @param template_name string Template to use
--- @param title string Document title
--- @param custom_metadata table|nil Additional metadata fields
--- @return boolean, string Success status and filepath
function M.create_document(template_name, title, custom_metadata)
  local templates = M.get_available_templates()
  local template = templates[template_name]

  if not template then
    utils.notify("Template not found: " .. template_name, vim.log.levels.ERROR)
    return false, nil
  end

  -- Generate filename
  local filename = utils.generate_filename(title, template.type)
  local notes_dir = config.get("notes_dir")
  local filepath = notes_dir .. "/" .. filename

  -- Check if file exists
  if utils.file_exists(filepath) then
    local confirm = vim.fn.confirm("File " .. filename .. " already exists. Overwrite?", "&Yes\n&No", 2)
    if confirm ~= 1 then
      utils.notify("Document creation cancelled", vim.log.levels.WARN)
      return false, nil
    end
  end

  -- Read template content
  local template_file = io.open(template.path, "r")
  if not template_file then
    utils.notify("Cannot read template file: " .. template.path, vim.log.levels.ERROR)
    return false, nil
  end

  local content = template_file:read("*all")
  template_file:close()

  -- Update metadata in template
  if template.has_metadata then
    content = M.update_template_metadata(content, title, custom_metadata)
  end

  -- Write new document
  local new_file = io.open(filepath, "w")
  if not new_file then
    utils.notify("Cannot create file: " .. filepath, vim.log.levels.ERROR)
    return false, nil
  end

  new_file:write(content)
  new_file:close()

  utils.notify("Created: " .. filename)
  return true, filepath
end

--- Update template metadata with user values
--- @param content string Template content
--- @param title string New document title
--- @param custom_metadata table|nil Additional metadata
--- @return string Updated content
function M.update_template_metadata(content, title, custom_metadata)
  custom_metadata = custom_metadata or {}

  -- Update title in metadata
  content = content:gsub('title: ".-"', 'title: "' .. title .. '"')

  -- Update date if auto_date is enabled
  if config.get("auto_date") then
    local today = os.date("%Y-%m-%d")
    content = content:gsub('date: ".-"', 'date: "' .. today .. '"')
  end

  -- Apply any custom metadata updates
  for key, value in pairs(custom_metadata) do
    if type(value) == "string" then
      content = content:gsub(key .. ': ".-"', key .. ': "' .. value .. '"')
    end
  end

  return content
end

--- Interactive template selection and document creation
function M.create_from_template()
  -- Check Typst availability
  if not utils.has_typst() then
    utils.notify("Typst binary not found. Please install Typst.", vim.log.levels.ERROR)
    return
  end

  -- Get available templates
  local templates = M.get_available_templates()

  if next(templates) == nil then
    utils.notify("No templates found in " .. config.get("template_dir"), vim.log.levels.WARN)
    return
  end

  -- Prepare template choices
  local choices = {}
  local template_map = {}

  for name, template in pairs(templates) do
    local display = string.format("%s: %s", template.type:upper(), template.title)
    table.insert(choices, display)
    template_map[display] = name
  end

  -- Sort choices
  table.sort(choices)

  -- Template selection
  utils.select(choices, {
    prompt = "Select template:",
  }, function(choice)
    if not choice then
      return
    end

    local template_name = template_map[choice]
    if not template_name then
      return
    end

    -- Get document title
    utils.input({
      prompt = "Document title: ",
      default = templates[template_name].type,
    }, function(title)
      if not title or title == "" then
        return
      end

      local success, filepath = M.create_document(template_name, title)
      if success then
        vim.cmd("edit " .. filepath)

        -- Auto-compile if enabled
        if config.get("auto_compile") then
          vim.defer_fn(function()
            require("typstwriter.compiler").compile_current()
          end, 500)
        end
      end
    end)
  end)
end

--- List available templates
function M.show_templates()
  local templates = M.get_available_templates()

  if next(templates) == nil then
    print("No templates found in " .. config.get("template_dir"))
    return
  end

  print("Available templates:")
  print("======================")

  for name, template in pairs(templates) do
    local status = template.has_metadata and "✓" or "!"
    print(string.format("  %s %-12s %s", status, name, template.description))
  end

  print("")
  print("✓ = Has metadata, ! = No metadata")
  print("Template directory: " .. config.get("template_dir"))
end

return M
