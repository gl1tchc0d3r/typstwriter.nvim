--- Configuration management for typst-templater.nvim
local M = {}

--- Default configuration
M.defaults = {
  -- Directory settings
  notes_dir = vim.fn.expand("~/Documents/notes"),
  template_dir = nil, -- Will default to notes_dir/typst-templates if nil

  -- File naming settings
  filename_format = "{name}.{code}.typ", -- Available: {name}, {code}, {date}
  code_length = 6,

  -- Compilation settings
  auto_compile = false,
  open_after_compile = true,

  -- Key mappings (set to false to disable)
  keymaps = {
    new_document = "<leader>Tn",
    compile = "<leader>Tp",
    open_pdf = "<leader>To",
    compile_and_open = "<leader>Tb",
    link_document = "<leader>Tl",
    -- Alternative short mappings
    pdf_generate = "<leader>Pg",
    pdf_open = "<leader>Po",
  },

  -- UI preferences
  use_modern_ui = true, -- Use vim.ui.select/input when available

  -- Notification settings
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO, -- INFO, WARN, ERROR
  },
}

--- Current configuration (merged with user config)
M.current = {}

--- Setup configuration with user overrides
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  user_config = user_config or {}

  -- Deep merge user config with defaults
  M.current = vim.tbl_deep_extend("force", M.defaults, user_config)

  -- Set template_dir default if not provided
  if not M.current.template_dir then
    M.current.template_dir = M.current.notes_dir .. "/typst-templates"
  end

  -- Expand paths
  M.current.notes_dir = vim.fn.expand(M.current.notes_dir)
  M.current.template_dir = vim.fn.expand(M.current.template_dir)

  -- Validate configuration
  M.validate()
end

--- Validate current configuration
function M.validate()
  -- Check if directories exist or can be created
  local notes_dir = M.current.notes_dir
  local template_dir = M.current.template_dir

  -- Create directories if they don't exist
  if vim.fn.isdirectory(notes_dir) == 0 then
    local success = vim.fn.mkdir(notes_dir, "p")
    if success == 0 then
      vim.notify("Failed to create notes directory: " .. notes_dir, vim.log.levels.ERROR)
    end
  end

  if vim.fn.isdirectory(template_dir) == 0 then
    local success = vim.fn.mkdir(template_dir, "p")
    if success == 0 then
      vim.notify("Failed to create template directory: " .. template_dir, vim.log.levels.ERROR)
    end
  end

  -- Validate filename format
  local format = M.current.filename_format
  if not format:match("{name}") then
    vim.notify("filename_format must contain {name} placeholder", vim.log.levels.ERROR)
    M.current.filename_format = M.defaults.filename_format
  end

  -- Validate code length
  if M.current.code_length < 1 or M.current.code_length > 20 then
    vim.notify("code_length must be between 1 and 20", vim.log.levels.WARN)
    M.current.code_length = M.defaults.code_length
  end
end

--- Get current configuration value
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
