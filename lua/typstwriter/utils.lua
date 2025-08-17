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

--- Check if directory exists
--- @param dirpath string Path to check
--- @return boolean True if directory exists
function M.dir_exists(dirpath)
  return vim.fn.isdirectory(dirpath) == 1
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

--- Show content in a floating window
--- @param title string Window title
--- @param content table|string Content lines (table of strings or single string)
--- @param opts table|nil Optional window configuration
--- @return integer, integer Buffer and window handles
function M.show_in_float(title, content, opts)
  opts = opts or {}

  -- Convert content to table of lines if it's a string
  if type(content) == "string" then
    content = vim.split(content, "\n", { plain = true })
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)

  -- Calculate window size
  local max_width = opts.max_width or 80
  local max_height = opts.max_height or 30
  local min_width = opts.min_width or 40
  local min_height = opts.min_height or 10

  -- Calculate content dimensions
  local content_width = 0
  for _, line in ipairs(content) do
    content_width = math.max(content_width, vim.fn.strdisplaywidth(line))
  end

  local width = math.max(min_width, math.min(max_width, content_width + 4))
  local height = math.max(min_height, math.min(max_height, #content + 2))

  -- Calculate position (center of screen)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create floating window
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = opts.border or "rounded",
    title = title,
    title_pos = opts.title_pos or "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "typstwriter-info")

  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Set keymaps to close window
  local close_keys = opts.close_keys or { "q", "<Esc>", "<CR>" }
  for _, key in ipairs(close_keys) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, ":close<CR>", {
      silent = true,
      noremap = true,
      desc = "Close TypstWriter info window",
    })
  end

  -- Add help text at bottom if enabled
  if opts.show_help ~= false then
    local help_text = "Press q, <Esc>, or <Enter> to close"
    vim.api.nvim_buf_set_extmark(buf, vim.api.nvim_create_namespace("typstwriter_help"), #content - 1, 0, {
      virt_text = { { help_text, "Comment" } },
      virt_text_pos = "eol",
    })
  end

  return buf, win
end

return M
