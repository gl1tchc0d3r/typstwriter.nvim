--- Compilation workflow for typstwriter.nvim
local metadata = require("typstwriter.metadata")
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

  -- Check Typst availability
  if not utils.has_typst() then
    utils.notify("Typst binary not found. Please install Typst.", vim.log.levels.ERROR)
    return false
  end

  -- Check file exists
  if not utils.file_exists(file_path) then
    utils.notify("File not found: " .. file_path, vim.log.levels.ERROR)
    return false
  end

  -- Validate metadata if required
  if config.get("require_metadata") then
    local meta = metadata.parse_metadata(file_path)
    if not meta then
      utils.notify("Document has no metadata. Add #metadata((...)) block.", vim.log.levels.WARN)
      return false
    end

    local valid, error_msg = config.validate_metadata(meta)
    if not valid then
      utils.notify("Invalid metadata: " .. error_msg, vim.log.levels.ERROR)
      return false
    end
  end

  -- Compile with Typst using home directory as root to access XDG directories
  -- This allows Typst to access the XDG package directory for bundled fonts and imports
  local home_dir = vim.fn.expand("~")
  local cmd = string.format('typst compile --root "%s" "%s"', home_dir, file_path)
  local success = utils.system_exec(cmd, "✓ Compiled to PDF", "✗ Compilation failed")

  return success
end

--- Open PDF for current Typst file
--- @param file_path string|nil Path to typst file (defaults to current buffer)
--- @return boolean True if PDF was opened
function M.open_pdf(file_path)
  file_path = file_path or vim.fn.expand("%:p")
  local pdf_file = utils.get_pdf_path(file_path)

  if not utils.file_exists(pdf_file) then
    utils.notify("PDF not found: " .. vim.fn.fnamemodify(pdf_file, ":t"), vim.log.levels.WARN)
    return false
  end

  local opener = utils.get_pdf_opener()
  if not opener then
    utils.notify("No PDF opener available", vim.log.levels.ERROR)
    return false
  end

  -- Open PDF asynchronously
  local success = vim.fn.jobstart({ opener, pdf_file }) > 0
  if success then
    utils.notify("Opened: " .. vim.fn.fnamemodify(pdf_file, ":t"))
  else
    utils.notify("Failed to open PDF", vim.log.levels.ERROR)
  end

  return success
end

--- Compile and open PDF
--- @param file_path string|nil Path to typst file (defaults to current buffer)
function M.compile_and_open(file_path)
  if M.compile_current(file_path) then
    -- Short delay then open PDF
    vim.defer_fn(function()
      M.open_pdf(file_path)
    end, 800)
  end
end

--- Get document status with metadata info
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
    metadata = nil,
    metadata_valid = false,
  }

  -- Get metadata information
  if status.typst_exists then
    status.metadata = metadata.parse_metadata(file_path)
    if status.metadata then
      local valid, error_msg = config.validate_metadata(status.metadata)
      status.metadata_valid = valid
      status.metadata_error = error_msg
    end
  end

  -- Check if PDF is outdated
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

  print("TypstWriter Status")
  print("====================")
  print("File: " .. status.typst_file)
  print("PDF:  " .. status.pdf_file)
  print("")

  -- System requirements
  print("System:")
  print("  Typst binary:     " .. (status.has_typst_binary and "✓" or "✗"))
  print("  PDF opener:       " .. (status.has_pdf_opener and "✓" or "✗"))
  print("")

  -- File status
  print("Files:")
  print("  Typst exists:     " .. (status.typst_exists and "✓" or "✗"))
  print("  PDF exists:       " .. (status.pdf_exists and "✓" or "✗"))
  if status.pdf_outdated ~= nil then
    print("  PDF up to date:   " .. (not status.pdf_outdated and "✓" or "✗"))
  end
  print("")

  -- Metadata status
  print("Metadata:")
  if status.metadata then
    print("  Has metadata:     ✓")
    print("  Type:             " .. (status.metadata.type or "none"))
    print("  Title:            " .. (status.metadata.title or "none"))
    print("  Status:           " .. (status.metadata.status or "none"))
    if status.metadata.tags and #status.metadata.tags > 0 then
      print("  Tags:             " .. table.concat(status.metadata.tags, ", "))
    end
    print("  Valid metadata:   " .. (status.metadata_valid and "✓" or "✗"))
    if not status.metadata_valid and status.metadata_error then
      print("  Error:            " .. status.metadata_error)
    end
  else
    print("  Has metadata:     ✗")
    print("  Note: Add #metadata((...)) block for enhanced features")
  end

  print("")

  -- Recommendations
  if not status.has_typst_binary then
    print("🔧 Install Typst: https://typst.app")
  elseif not status.metadata then
    print("💡 Add metadata block for enhanced features")
  elseif not status.metadata_valid then
    print("⚠️  Fix metadata: " .. (status.metadata_error or "Unknown error"))
  elseif status.pdf_outdated then
    print("💡 Run :TypstWriterCompile to update PDF")
  elseif status.typst_exists and not status.pdf_exists then
    print("💡 Run :TypstWriterCompile to generate PDF")
  else
    print("✅ Everything looks good!")
  end
end

return M
