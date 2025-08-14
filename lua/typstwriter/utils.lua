--- Utilities for typstwriter.nvim
local config = require("typstwriter.config")
local M = {}

--- Generate filename for new document
--- @param title string Document title from metadata
--- @param doc_type string Document type from metadata (unused, kept for compatibility)
--- @return string Generated filename
function M.generate_filename(title, doc_type)
  local safe_title = title:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):lower()

  -- Add random suffix if enabled
  if config.get("use_random_suffix") then
    local suffix = M.generate_random_suffix(config.get("random_suffix_length") or 6)
    return string.format("%s.%s.typ", safe_title, suffix)
  else
    return string.format("%s.typ", safe_title)
  end
end

--- Generate random alphanumeric suffix
--- @param length integer Length of suffix
--- @return string Random suffix
function M.generate_random_suffix(length)
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local result = ""

  math.randomseed(os.time() + vim.fn.getpid())

  for i = 1, length do
    local idx = math.random(1, #chars)
    result = result .. chars:sub(idx, idx)
  end

  return result
end

--- Safe notification wrapper
--- @param message string Message to display
--- @param level integer|nil Log level
function M.notify(message, level)
  if not config.should_notify() then
    return
  end

  level = level or config.get_notification_level()
  vim.notify("[TypstWriter] " .. message, level)
end

--- Check if Typst binary is available
--- @return boolean True if typst is available
function M.has_typst()
  return vim.fn.executable("typst") == 1
end

--- Get PDF path for a Typst file
--- @param typst_file string Path to .typ file
--- @return string Path to corresponding .pdf file
function M.get_pdf_path(typst_file)
  return vim.fn.fnamemodify(typst_file, ":r") .. ".pdf"
end

--- Check if file exists
--- @param filepath string Path to check
--- @return boolean True if file exists
function M.file_exists(filepath)
  return vim.fn.filereadable(filepath) == 1
end

--- Get platform-appropriate PDF opener
--- @return string|nil PDF opener command
function M.get_pdf_opener()
  if vim.fn.has("mac") == 1 then
    return "open"
  elseif vim.fn.has("unix") == 1 then
    return "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    return "start"
  end
  return nil
end

--- Execute system command with error handling
--- @param cmd string Command to execute
--- @param success_msg string|nil Success message
--- @param error_msg string|nil Error message
--- @return boolean True if successful
function M.system_exec(cmd, success_msg, error_msg)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  if success then
    if success_msg then
      M.notify(success_msg)
    end
  else
    local msg = error_msg or ("Command failed: " .. cmd)
    M.notify(msg, vim.log.levels.ERROR)
    if output and output ~= "" then
      print("Error details: " .. output)
    end
  end

  return success
end

--- Modern UI wrapper for input
--- @param opts table Input options
--- @param callback function Callback function
function M.input(opts, callback)
  if vim.ui and vim.ui.input then
    vim.ui.input(opts, callback)
  else
    -- Simple fallback
    local result = vim.fn.input(opts.prompt or "", opts.default or "")
    if callback then
      callback(result ~= "" and result or nil)
    end
  end
end

--- Modern UI wrapper for selection
--- @param items table List of items
--- @param opts table Selection options
--- @param callback function Callback function
function M.select(items, opts, callback)
  if vim.ui and vim.ui.select then
    vim.ui.select(items, opts, callback)
  else
    -- Simple fallback
    print(opts.prompt or "Select an option:")
    for i, item in ipairs(items) do
      print(i .. ". " .. tostring(item))
    end

    local choice = vim.fn.input("Select (1-" .. #items .. "): ")
    local idx = tonumber(choice)

    if callback then
      if idx and idx >= 1 and idx <= #items then
        callback(items[idx])
      else
        callback(nil)
      end
    end
  end
end

--- Capitalize first letter of string
--- @param str string Input string
--- @return string Capitalized string
function M.capitalize(str)
  if not str or str == "" then
    return str
  end
  return str:gsub("^%l", string.upper)
end

return M
