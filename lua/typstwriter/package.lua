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

  print("typstwriter Package Status (XDG)")
  print("================================")
  print("Platform: " .. platform.os)
  print("XDG Data Dir: " .. platform.data_dir)
  print("Package Dir:  " .. platform.package_dir)
  print("Template Dir: " .. status.template_dir)
  print("")
  print("Package installed:  " .. (status.package_installed and "✓" or "✗"))
  print("Templates count:    " .. status.templates_count)
  print("")

  if not status.package_installed then
    print("⚠️  Package not installed at XDG location.")
    print("   Run :TypstWriterSetup to install with fonts and XDG compliance.")
  else
    print("✅ XDG package system ready!")
    print("📁 Package includes bundled fonts (" .. "32MB" .. ")")
  end
end

return M
