--- Cross-platform path utilities for typstwriter.nvim
--- Implements XDG Base Directory specification for proper system integration
---
local M = {}

--- Get XDG data directory for the current platform
--- @return string XDG data directory path
function M.get_data_dir()
  -- Check for XDG_DATA_HOME first (Linux/Unix standard)
  local xdg_data_home = vim.env.XDG_DATA_HOME
  if xdg_data_home and xdg_data_home ~= "" then
    return xdg_data_home .. "/nvim"
  end

  -- Use vim.fn.stdpath which handles platform differences
  -- Linux: ~/.local/share/nvim
  -- macOS: ~/Library/Application Support/nvim
  -- Windows: %LOCALAPPDATA%/nvim
  return vim.fn.stdpath("data")
end

--- Get XDG cache directory for the current platform
--- @return string XDG cache directory path
function M.get_cache_dir()
  -- Check for XDG_CACHE_HOME first (Linux/Unix standard)
  local xdg_cache_home = vim.env.XDG_CACHE_HOME
  if xdg_cache_home and xdg_cache_home ~= "" then
    return xdg_cache_home .. "/nvim"
  end

  -- Use vim.fn.stdpath which handles platform differences
  -- Linux: ~/.cache/nvim
  -- macOS: ~/Library/Caches/nvim
  -- Windows: %TEMP%/nvim
  return vim.fn.stdpath("cache")
end

--- Get typstwriter package directory (canonical package location)
--- @return string Package directory path
function M.get_package_dir()
  return M.get_data_dir() .. "/typstwriter/packages/typstwriter"
end

--- Get typstwriter cache directory (for temporary files)
--- @return string Cache directory path
function M.get_typstwriter_cache_dir()
  return M.get_cache_dir() .. "/typstwriter"
end

--- Ensure a directory exists, creating it if necessary
--- @param dir string Directory path to ensure
--- @return boolean Success status
function M.ensure_directory(dir)
  if vim.fn.isdirectory(dir) == 0 then
    local success = vim.fn.mkdir(dir, "p")
    if success == 0 then
      return false
    end
  end
  return true
end

--- Ensure all typstwriter directories exist
--- @return boolean Success status
function M.ensure_typstwriter_directories()
  local dirs = {
    M.get_data_dir(),
    M.get_package_dir(),
    M.get_typstwriter_cache_dir(),
  }

  for _, dir in ipairs(dirs) do
    if not M.ensure_directory(dir) then
      return false, "Failed to create directory: " .. dir
    end
  end

  return true
end

--- Get platform-specific information for debugging
--- @return table Platform information
function M.get_platform_info()
  return {
    os = vim.loop.os_uname().sysname,
    data_dir = M.get_data_dir(),
    cache_dir = M.get_cache_dir(),
    package_dir = M.get_package_dir(),
    cache_dir_typst = M.get_typstwriter_cache_dir(),
    xdg_data_home = vim.env.XDG_DATA_HOME,
    xdg_cache_home = vim.env.XDG_CACHE_HOME,
  }
end

--- Check if package is installed at the canonical location
--- @return boolean, string Installation status and path
function M.check_package_installation()
  local package_dir = M.get_package_dir()
  local manifest_path = package_dir .. "/typst.toml"
  local core_path = package_dir .. "/core/base.typ"
  local fonts_path = package_dir .. "/fonts"

  if
    vim.fn.filereadable(manifest_path) == 1
    and vim.fn.filereadable(core_path) == 1
    and vim.fn.isdirectory(fonts_path) == 1
  then
    return true, package_dir
  end

  return false, package_dir
end

return M
