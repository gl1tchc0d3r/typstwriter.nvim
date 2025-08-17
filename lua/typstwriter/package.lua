--- Package setup system for typstwriter.nvim
--- Manages the typstwriter package in XDG-compliant directories
local utils = require("typstwriter.utils")
local templates = require("typstwriter.templates")
local paths = require("typstwriter.paths")
local M = {}

--- Check if typstwriter package is installed (XDG location)
--- @return boolean True if package is installed
function M.is_package_installed()
  local installed, _ = paths.check_package_installation()
  return installed
end

--- Install/update the typstwriter package to XDG location
--- @return boolean True if installation succeeded
function M.install_package()
  local success, message = templates.install_package()
  if success then
    utils.notify(message, vim.log.levels.INFO)
  else
    utils.notify(message, vim.log.levels.ERROR)
  end
  return success
end

--- Setup templates with XDG package imports
--- @return boolean True if setup succeeded
function M.setup_templates()
  local success, message = templates.install_templates()
  if success then
    utils.notify(message, vim.log.levels.INFO)
  else
    utils.notify(message, vim.log.levels.ERROR)
  end
  return success
end

--- Complete package setup (install package + setup templates)
--- @return boolean True if complete setup succeeded
function M.setup()
  local success, message = templates.setup_complete()
  if success then
    utils.notify(message, vim.log.levels.INFO)
  else
    utils.notify(message, vim.log.levels.ERROR)
  end
  return success
end

--- Get package status information
--- @return table Status information
function M.status()
  return templates.check_installation_status()
end

--- Show package status
function M.show_status()
  local status = M.status()
  local platform = status.platform

  -- Build content for floating window
  local content = {
    "TypstWriter Package Status",
    "==========================",
    "",
    "Platform Information:",
    "  OS:             " .. platform.os,
    "  XDG Data Dir:   " .. platform.data_dir,
    "  Package Dir:    " .. platform.package_dir,
    "  Template Dir:   " .. status.template_dir,
    "",
    "Installation Status:",
    "  Package installed:  " .. (status.package_installed and "✓ Yes" or "✗ No"),
    "  Templates count:    " .. status.templates_count,
    "",
  }

  -- Add status-specific information
  if not status.package_installed then
    table.insert(content, "Status: Not Ready")
    table.insert(content, "⚠️  Package not installed at XDG location")
    table.insert(content, "")
    table.insert(content, "Next Steps:")
    table.insert(content, "  1. Run :TypstWriter setup")
    table.insert(content, "  2. This will install fonts and ensure XDG compliance")
  else
    table.insert(content, "Status: Ready")
    table.insert(content, "✅ XDG package system is operational!")
    table.insert(content, "📁 Package includes bundled fonts (~32MB)")
    table.insert(content, "")
    table.insert(content, "Available Commands:")
    table.insert(content, "  :TypstWriter new          - Create new document")
    table.insert(content, "  :TypstWriter templates list - List templates")
  end

  -- Show in floating window
  utils.show_in_float("Package Status", content, {
    min_width = 60,
    max_width = 90,
  })
end

return M
