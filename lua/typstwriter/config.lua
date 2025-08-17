--- Configuration system for typstwriter.nvim
---
local M = {}

--- Default configuration
M.defaults = {
  -- Directory settings
  notes_dir = vim.fn.expand("~/Documents/notes"),
  template_dir = nil, -- Will default to notes_dir/templates
  database_dir = nil, -- Will default to notes_dir/database

  -- Template preferences
  default_template_type = "note",
  auto_date = true, -- Automatically set date to today

  -- Filename generation
  use_random_suffix = true, -- Add random suffix to filenames for uniqueness
  random_suffix_length = 6, -- Length of random suffix

  -- Compilation settings
  auto_compile = false,
  open_after_compile = true,

  -- Metadata validation
  require_metadata = true,
  required_fields = { "type", "title" },

  -- Database settings
  database = {
    enabled = true,
    filename = "typstwriter.db",     -- Database filename
    auto_create = true,              -- Create database if doesn't exist
    backup_enabled = true,           -- Enable automatic backups
    backup_count = 5,                -- Number of backups to keep
  },

  -- Key mappings following CLI command structure
  keymaps = {
    -- Main commands
    new_document = "<leader>Tn", -- TypstWriter new
    setup = "<leader>Ts", -- TypstWriter setup
    help = "<leader>Th", -- TypstWriter help

    -- Document operations (Td prefix)
    compile = "<leader>Tdc", -- TypstWriter compile
    open_pdf = "<leader>Tdo", -- TypstWriter open
    compile_and_open = "<leader>Tdb", -- TypstWriter both
    status = "<leader>Tds", -- TypstWriter status

    -- Template operations (Tt prefix)
    list_templates = "<leader>Ttl", -- TypstWriter templates list
    copy_templates = "<leader>Ttc", -- TypstWriter templates copyexamples

    -- Search operations (TS prefix)
    search = "<leader>TS", -- TypstWriter search
    recent = "<leader>TSr", -- TypstWriter recent
    stats = "<leader>TSs", -- TypstWriter stats
    refresh_index = "<leader>TSi", -- TypstWriter refresh
    rebuild_index = "<leader>TSI", -- TypstWriter rebuild

    -- Package operations (Tp prefix)
    package_status = "<leader>Tps", -- TypstWriter package status
  },

  -- Notifications
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO,
  },
}

--- Current configuration
M.current = {}

--- Setup configuration
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  user_config = user_config or {}

  -- Merge user config with defaults
  M.current = vim.tbl_deep_extend("force", M.defaults, user_config)

  -- Set template_dir default if not provided
  if not M.current.template_dir then
    M.current.template_dir = M.current.notes_dir .. "/templates"
  end

  -- Set database_dir default if not provided
  if not M.current.database_dir then
    M.current.database_dir = M.current.notes_dir .. "/database"
  end

  -- Expand paths
  M.current.notes_dir = vim.fn.expand(M.current.notes_dir)
  M.current.template_dir = vim.fn.expand(M.current.template_dir)
  M.current.database_dir = vim.fn.expand(M.current.database_dir)

  -- Create directories if needed
  M.ensure_directories()
end

--- Ensure required directories exist
function M.ensure_directories()
  local dirs = { M.current.notes_dir, M.current.template_dir, M.current.database_dir }

  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 0 then
      local success = vim.fn.mkdir(dir, "p")
      if success == 0 then
        vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
      end
    end
  end
end

--- Get configuration value
--- @param key string Configuration key (supports dot notation)
--- @return any Configuration value
function M.get(key)
  local keys = vim.split(key, ".", { plain = true })
  local value = M.current

  for _, k in ipairs(keys) do
    if type(value) == "table" and value[k] ~= nil then
      value = value[k]
    else
      return nil
    end
  end

  return value
end

--- Validate metadata against required fields
--- @param metadata table Metadata to validate
--- @return boolean, string True if valid, or false with error message
function M.validate_metadata(metadata)
  if not M.get("require_metadata") then
    return true
  end

  local required = M.get("required_fields") or {}
  for _, field in ipairs(required) do
    if not metadata[field] or metadata[field] == "" then
      return false, "Missing required field: " .. field
    end
  end

  return true
end

--- Check if notifications are enabled
--- @return boolean
function M.should_notify()
  return M.get("notifications.enabled") == true
end

--- Get notification level
--- @return integer Log level
function M.get_notification_level()
  return M.get("notifications.level") or vim.log.levels.INFO
end

return M
