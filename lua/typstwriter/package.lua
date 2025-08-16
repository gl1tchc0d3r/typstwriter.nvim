--- Package setup system for typstwriter.nvim
--- Manages the typstwriter package in user's configured template directory
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local M = {}

--- Get the plugin's package source directory
--- @return string Path to the plugin's package directory
local function get_plugin_package_dir()
  -- Get the directory where this Lua file is located
  local plugin_root = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h:h")
  return plugin_root .. "/packages"
end

--- Get the user's package destination directory
--- @return string Path where packages should be installed in user's template_dir
local function get_user_package_dir()
  local template_dir = config.get("template_dir")
  if not template_dir then
    error("Template directory not configured")
  end
  return template_dir .. "/packages"
end

--- Check if typstwriter package is installed in user's template directory
--- @return boolean True if package is installed and up to date
function M.is_package_installed()
  local user_package_dir = get_user_package_dir()
  local package_manifest = user_package_dir .. "/typstwriter/typst.toml"
  
  -- Check if package exists
  if vim.fn.filereadable(package_manifest) == 0 then
    return false
  end
  
  -- TODO: Could add version checking here in the future
  return true
end

--- Read file contents safely
--- @param filepath string Path to file to read
--- @return string|nil File contents or nil if error
local function read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

--- Install/update the typstwriter package to user's template directory
--- @return boolean True if installation succeeded
function M.install_package()
  local plugin_package_dir = get_plugin_package_dir()
  local user_package_dir = get_user_package_dir()
  
  -- Ensure the source package exists
  if vim.fn.isdirectory(plugin_package_dir) == 0 then
    utils.notify("Plugin package directory not found: " .. plugin_package_dir, vim.log.levels.ERROR)
    return false
  end
  
  -- Create user's package directory
  local success = vim.fn.mkdir(user_package_dir, "p")
  if success == 0 then
    utils.notify("Failed to create package directory: " .. user_package_dir, vim.log.levels.ERROR)
    return false
  end
  
  -- Copy the package
  local copy_cmd = string.format("cp -r %s/* %s/", plugin_package_dir, user_package_dir)
  local result = vim.fn.system(copy_cmd)
  
  if vim.v.shell_error ~= 0 then
    utils.notify("Failed to copy package: " .. result, vim.log.levels.ERROR)
    return false
  end
  
  utils.notify("typstwriter package installed successfully", vim.log.levels.INFO)
  return true
end

--- Remove the typstwriter package from user's template directory
--- @return boolean True if removal succeeded
function M.remove_package()
  local user_package_dir = get_user_package_dir()
  
  if vim.fn.isdirectory(user_package_dir) == 0 then
    utils.notify("Package not installed", vim.log.levels.INFO)
    return true
  end
  
  local remove_cmd = string.format("rm -rf %s", user_package_dir)
  local result = vim.fn.system(remove_cmd)
  
  if vim.v.shell_error ~= 0 then
    utils.notify("Failed to remove package: " .. result, vim.log.levels.ERROR)
    return false
  end
  
  utils.notify("typstwriter package removed", vim.log.levels.INFO)
  return true
end

--- Setup initial templates in user's template directory
--- @return boolean True if setup succeeded
function M.setup_templates()
  local template_dir = config.get("template_dir")
  local plugin_template_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h:h") .. "/templates"
  
  -- Ensure template directory exists
  local success = vim.fn.mkdir(template_dir, "p")
  if success == 0 then
    utils.notify("Failed to create template directory: " .. template_dir, vim.log.levels.ERROR)
    return false
  end
  
  -- Copy templates, but adjust import paths
  local template_files = vim.fn.glob(plugin_template_dir .. "/*.typ", false, true)
  
  for _, source_file in ipairs(template_files) do
    local basename = vim.fn.fnamemodify(source_file, ":t")
    local dest_file = template_dir .. "/" .. basename
    
    -- Skip if template already exists (don't overwrite user customizations)
    if vim.fn.filereadable(dest_file) == 0 then
      -- Read template content
      local content = read_file(source_file)
      if content then
        -- Update import paths to use relative path in user's directory
        content = content:gsub([[#import "%.%./packages/typstwriter/]], [[#import "./packages/typstwriter/]])
        content = content:gsub([[#import "%.%./packages/typstwriter/core/]], [[#import "./packages/typstwriter/core/]])
        
        -- Write updated template
        local file = io.open(dest_file, "w")
        if file then
          file:write(content)
          file:close()
          utils.notify("Template installed: " .. basename, vim.log.levels.INFO)
        else
          utils.notify("Failed to create template: " .. basename, vim.log.levels.ERROR)
        end
      end
    else
      utils.notify("Template already exists (skipping): " .. basename, vim.log.levels.INFO)
    end
  end
  
  return true
end

--- Complete package setup (install package + setup templates)
--- @return boolean True if complete setup succeeded
function M.setup()
  utils.notify("Setting up typstwriter package system...", vim.log.levels.INFO)
  
  -- Install package
  if not M.install_package() then
    return false
  end
  
  -- Setup templates
  if not M.setup_templates() then
    return false
  end
  
  utils.notify("typstwriter package setup complete!", vim.log.levels.INFO)
  utils.notify("Templates are now available in: " .. config.get("template_dir"), vim.log.levels.INFO)
  return true
end

--- Get package status information
--- @return table Status information
function M.status()
  local template_dir = config.get("template_dir")
  local user_package_dir = get_user_package_dir()
  
  return {
    template_dir = template_dir,
    package_dir = user_package_dir,
    package_installed = M.is_package_installed(),
    templates_exist = vim.fn.isdirectory(template_dir) == 1 and #vim.fn.glob(template_dir .. "/*.typ", false, true) > 0
  }
end

--- Show package status
function M.show_status()
  local status = M.status()
  
  print("typstwriter Package Status")
  print("==========================")
  print("Template directory: " .. status.template_dir)
  print("Package directory:  " .. status.package_dir)
  print("")
  print("Package installed:  " .. (status.package_installed and "✓" or "✗"))
  print("Templates exist:    " .. (status.templates_exist and "✓" or "✗"))
  print("")
  
  if not status.package_installed then
    print("⚠️  Package not installed. Run :TypstWriterSetup to install.")
  elseif not status.templates_exist then
    print("⚠️  No templates found. Run :TypstWriterSetup to install templates.")
  else
    print("✅ Package system ready!")
  end
end

return M
