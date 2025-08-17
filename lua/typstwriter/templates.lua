--- Metadata-driven template system for typstwriter.nvim
local metadata = require("typstwriter.metadata")
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local paths = require("typstwriter.paths")
local M = {}

--- Get available templates (fast - no metadata parsing)
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
      -- Fast template info - filename is the type!
      templates[basename] = {
        name = basename,
        title = utils.capitalize(basename),
        type = basename, -- filename IS the type
        description = utils.capitalize(basename) .. " template",
        path = filepath,
        has_metadata = true, -- Assume our PKM templates have metadata
      }
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

  -- Fix import paths for documents created in notes_dir
  -- Ensure XDG package paths are used in created documents
  content = M.update_template_imports(content, notes_dir)

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
    local display = string.format("OBJECT: %s", template.title)
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
            require("typstwriter.document").compile_current()
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

--- Install typstwriter package to XDG-compliant location
--- @return boolean, string Success status and message
function M.install_package()
  -- Ensure XDG directories exist
  local success, error_msg = paths.ensure_typstwriter_directories()
  if not success then
    return false, error_msg
  end

  -- Get source and destination paths
  local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
  local source_package = plugin_root .. "/packages/typstwriter"
  local dest_package = paths.get_package_dir()

  -- Check if source package exists
  if vim.fn.isdirectory(source_package) == 0 then
    return false, "Source package not found: " .. source_package
  end

  -- Copy package to XDG location
  local cmd = string.format("cp -r %s/* %s/", vim.fn.shellescape(source_package), vim.fn.shellescape(dest_package))
  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return false, "Failed to copy package: " .. result
  end

  -- Verify installation
  local installed, package_path = paths.check_package_installation()
  if installed then
    return true, "Package installed to: " .. package_path
  else
    return false, "Package installation verification failed"
  end
end

--- Install templates to template directory with XDG package imports
--- @return boolean, string Success status and message
function M.install_templates()
  local template_dir = config.get("template_dir")

  -- Ensure template directory exists
  if not paths.ensure_directory(template_dir) then
    return false, "Failed to create template directory: " .. template_dir
  end

  -- Check if package is installed
  local package_installed = paths.check_package_installation()
  if not package_installed then
    return false, "Package not installed. Run :TypstWriter package install first."
  end

  -- Get source templates from plugin
  local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
  local source_templates = plugin_root .. "/templates"

  if vim.fn.isdirectory(source_templates) == 0 then
    return false, "Source templates not found: " .. source_templates
  end

  -- Copy templates and update import paths
  local template_files = vim.fn.glob(source_templates .. "/*.typ", false, true)
  local installed_count = 0

  for _, source_file in ipairs(template_files) do
    local filename = vim.fn.fnamemodify(source_file, ":t")
    local dest_file = template_dir .. "/" .. filename

    -- Read source template
    local source_handle = io.open(source_file, "r")
    if source_handle then
      local content = source_handle:read("*all")
      source_handle:close()

      -- Update import paths to use XDG package location
      content = M.update_template_imports(content, template_dir)

      -- Write updated template
      local dest_handle = io.open(dest_file, "w")
      if dest_handle then
        dest_handle:write(content)
        dest_handle:close()
        installed_count = installed_count + 1
      end
    end
  end

  if installed_count > 0 then
    return true, string.format("Installed %d templates to: %s", installed_count, template_dir)
  else
    return false, "No templates were installed"
  end
end

--- Update template import paths to use correct relative paths from document location to XDG package
--- @param content string Template content
--- @param from_dir string Directory where the document is located (typically notes_dir)
--- @return string Updated content with import paths that work with Typst
function M.update_template_imports(content, from_dir)
  local package_dir = paths.get_package_dir()
  local relative_path = paths.get_relative_path(from_dir, package_dir)

  -- Replace various import patterns with correct relative paths to XDG location
  -- Match "./packages/typstwriter/", "../packages/typstwriter/", and absolute-style paths
  content = content:gsub('"%.%.%/packages%/typstwriter%/', '"' .. relative_path .. "/")
  content = content:gsub('"%.%/packages%/typstwriter%/', '"' .. relative_path .. "/")
  -- Also match existing absolute-style XDG paths that may be incorrect
  content = content:gsub('"[^"]*%.local/share/nvim/typstwriter/packages/typstwriter/', '"' .. relative_path .. "/")
  content = content:gsub('"[^"]*typstwriter/packages/typstwriter/', '"' .. relative_path .. "/")
  return content
end

--- Complete setup: install package and templates
--- @return boolean, string Success status and message
function M.setup_complete()
  utils.notify("Setting up typstwriter package system...", vim.log.levels.INFO)

  -- Install package to XDG location
  local package_success, package_msg = M.install_package()
  if not package_success then
    return false, "Package installation failed: " .. package_msg
  end

  utils.notify(package_msg, vim.log.levels.INFO)

  -- Install templates with XDG imports
  local template_success, template_msg = M.install_templates()
  if not template_success then
    return false, "Template installation failed: " .. template_msg
  end

  utils.notify(template_msg, vim.log.levels.INFO)

  return true, "typstwriter package system setup complete!"
end

--- Check installation status
--- @return table Status information
function M.check_installation_status()
  local package_installed, package_path = paths.check_package_installation()
  local platform_info = paths.get_platform_info()

  return {
    package_installed = package_installed,
    package_path = package_path,
    template_dir = config.get("template_dir"),
    platform = platform_info,
    templates_count = vim.tbl_count(M.get_available_templates()),
  }
end

return M
