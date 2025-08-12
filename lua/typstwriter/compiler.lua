--- PDF compilation workflow for typstwriter.nvim
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local M = {}

--- Compile current Typst file to PDF
--- @param file_path string|nil Path to file (defaults to current buffer)
--- @return boolean True if compilation succeeded
function M.compile_current(file_path)
  file_path = file_path or vim.fn.expand("%:p")

  -- Check if it's a Typst file
  if vim.fn.expand("%:e") ~= "typ" then
    utils.notify("Not a Typst file", vim.log.levels.WARN)
    return false
  end

  -- Check if typst is available
  if not utils.has_typst() then
    utils.notify("Typst binary not found in PATH. Please install Typst.", vim.log.levels.ERROR)
    return false
  end

  -- Check if file exists
  if not utils.file_exists(file_path) then
    utils.notify("File not found: " .. file_path, vim.log.levels.ERROR)
    return false
  end

  local cmd = string.format('typst compile "%s"', file_path)
  return utils.system_exec(cmd, "Typst compiled to PDF", "Typst compilation failed")
end

--- Open PDF for current Typst file
--- @param file_path string|nil Path to typst file (defaults to current buffer)
--- @return boolean True if PDF was opened successfully
function M.open_pdf(file_path)
  file_path = file_path or vim.fn.expand("%:p")
  local pdf_file = utils.get_pdf_path(file_path)

  if not utils.file_exists(pdf_file) then
    utils.notify("PDF not found: " .. pdf_file, vim.log.levels.WARN)
    return false
  end

  local opener = utils.get_pdf_opener()
  if not opener then
    utils.notify("No PDF opener available for this platform", vim.log.levels.ERROR)
    return false
  end

  -- Use jobstart for non-blocking execution
  local success = vim.fn.jobstart({ opener, pdf_file }) > 0
  if success then
    utils.notify("Opened PDF: " .. vim.fn.fnamemodify(pdf_file, ":t"))
  else
    utils.notify("Failed to open PDF", vim.log.levels.ERROR)
  end

  return success
end

--- Compile current file and open PDF
--- @param file_path string|nil Path to typst file (defaults to current buffer)
function M.compile_and_open(file_path)
  if M.compile_current(file_path) then
    -- Wait a bit for compilation to finish, then open PDF
    local delay = 1000 -- 1 second
    vim.defer_fn(function()
      M.open_pdf(file_path)
    end, delay)
  end
end

--- Watch and auto-compile file on save (if enabled)
--- @param file_path string Path to typst file
function M.setup_auto_compile(file_path)
  if not config.get("auto_compile") then
    return
  end

  -- Create autocommand for this specific file
  local augroup = vim.api.nvim_create_augroup("TWriterAutoCompile", { clear = false })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = file_path,
    callback = function()
      M.compile_current(file_path)

      if config.get("open_after_compile") then
        vim.defer_fn(function()
          M.open_pdf(file_path)
        end, 500)
      end
    end,
    desc = "Auto-compile Typst file on save",
  })
end

--- Get compilation status for a file
--- @param file_path string|nil Path to typst file (defaults to current buffer)
--- @return table Status information
function M.get_status(file_path)
  file_path = file_path or vim.fn.expand("%:p")
  local pdf_file = utils.get_pdf_path(file_path)

  local status = {
    typst_file = file_path,
    pdf_file = pdf_file,
    typst_exists = utils.file_exists(file_path),
    pdf_exists = utils.file_exists(pdf_file),
    has_typst_binary = utils.has_typst(),
    has_pdf_opener = utils.get_pdf_opener() ~= nil,
  }

  -- Check modification times if both files exist
  if status.typst_exists and status.pdf_exists then
    local typst_time = vim.fn.getftime(file_path)
    local pdf_time = vim.fn.getftime(pdf_file)
    status.pdf_outdated = pdf_time < typst_time
  else
    status.pdf_outdated = status.typst_exists and not status.pdf_exists
  end

  return status
end

--- Show compilation status for current file
function M.show_status()
  local status = M.get_status()

  print("Typst Compilation Status")
  print("========================")
  print("Typst file: " .. status.typst_file)
  print("PDF file:   " .. status.pdf_file)
  print("")
  print("Typst binary available: " .. (status.has_typst_binary and "✓" or "✗"))
  print("PDF opener available:   " .. (status.has_pdf_opener and "✓" or "✗"))
  print("Typst file exists:      " .. (status.typst_exists and "✓" or "✗"))
  print("PDF file exists:        " .. (status.pdf_exists and "✓" or "✗"))

  if status.pdf_outdated ~= nil then
    print("PDF up to date:         " .. (not status.pdf_outdated and "✓" or "✗"))
  end

  print("")

  -- Provide recommendations
  if not status.has_typst_binary then
    print("⚠ Install Typst binary: https://github.com/typst/typst")
  elseif status.pdf_outdated then
    print("💡 PDF is outdated. Run :TWriterCompile to update")
  elseif status.typst_exists and not status.pdf_exists then
    print("💡 No PDF found. Run :TWriterCompile to generate")
  end
end

return M
