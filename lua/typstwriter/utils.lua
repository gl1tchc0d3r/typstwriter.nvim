--- Utility functions for typstwriter.nvim
local config = require("typstwriter.config")
local M = {}

--- Generate a random alphanumeric code
--- @param length number Length of the code to generate
--- @return string Random code
function M.generate_unique_code(length)
  length = length or config.get("code_length") or 6
  local chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local code = ""

  -- Seed random number generator
  math.randomseed(os.time() + os.clock() * 1000000)

  for _ = 1, length do
    local idx = math.random(1, #chars)
    code = code .. string.sub(chars, idx, idx)
  end

  return code
end

--- Format filename using template placeholders
--- @param name string Document name
--- @param template_format string|nil Format template (defaults to config)
--- @return string Formatted filename
function M.format_filename(name, template_format)
  template_format = template_format or config.get("filename_format")
  local code = M.generate_unique_code()
  local date = os.date("%Y-%m-%d")

  -- Replace placeholders
  local filename = template_format:gsub("{name}", name):gsub("{code}", code):gsub("{date}", date)

  -- Ensure .typ extension
  if not filename:match("%.typ$") then
    filename = filename .. ".typ"
  end

  return filename
end

--- Safe notification that respects user settings
--- @param message string Message to display
--- @param level integer|nil Log level (defaults to INFO)
function M.notify(message, level)
  if not config.should_notify() then
    return
  end

  level = level or config.get_notification_level()
  vim.notify(message, level)
end

--- Check if a file exists and is readable
--- @param filepath string Path to check
--- @return boolean True if file exists and is readable
function M.file_exists(filepath)
  return vim.fn.filereadable(filepath) == 1
end

--- Check if a directory exists
--- @param dirpath string Directory path to check
--- @return boolean True if directory exists
function M.dir_exists(dirpath)
  return vim.fn.isdirectory(dirpath) == 1
end

--- Get the PDF filepath for a given typst file
--- @param typst_file string Path to .typ file
--- @return string Path to corresponding .pdf file
function M.get_pdf_path(typst_file)
  if not typst_file then
    typst_file = vim.fn.expand("%:p")
  end
  return vim.fn.fnamemodify(typst_file, ":r") .. ".pdf"
end

--- Check if typst binary is available
--- @return boolean True if typst is in PATH
function M.has_typst()
  return vim.fn.executable("typst") == 1
end

--- Get platform-appropriate PDF opener command
--- @return string|nil Command to open PDFs, nil if not available
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

--- Execute a system command safely with error handling
--- @param cmd string Command to execute
--- @param success_msg string|nil Message on success
--- @param error_msg string|nil Message on error
--- @return boolean True if command succeeded
function M.system_exec(cmd, success_msg, error_msg)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  if success then
    if success_msg then
      M.notify(success_msg, vim.log.levels.INFO)
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

--- Check if modern UI (vim.ui.select/input) should be used
--- @return boolean True if modern UI is available and enabled
function M.use_modern_ui()
  return config.get("use_modern_ui") and vim.ui and vim.ui.select and vim.ui.input
end

--- Safe wrapper for user input with fallback
--- @param opts table Input options
--- @param callback function Callback function
function M.input(opts, callback)
  if M.use_modern_ui() then
    vim.ui.input(opts, callback)
  else
    -- Fallback to vim.fn.input
    local result = vim.fn.input(opts.prompt or "", opts.default or "")
    if callback then
      callback(result ~= "" and result or nil)
    end
  end
end

--- Safe wrapper for selection with fallback
--- @param items table List of items to select from
--- @param opts table Selection options
--- @param callback function Callback function
function M.select(items, opts, callback)
  if M.use_modern_ui() then
    vim.ui.select(items, opts, callback)
  else
    -- Fallback to numbered menu
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

--- Capitalize first letter of a string
--- @param str string Input string
--- @return string String with first letter capitalized
function M.capitalize(str)
  if not str or str == "" then
    return str
  end
  return str:gsub("^%l", string.upper)
end

return M
