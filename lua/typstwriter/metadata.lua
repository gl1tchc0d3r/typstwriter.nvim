--- Simple metadata extraction using Typst query command
local M = {}

--- Parse metadata from a Typst file using `typst query`
--- @param filepath string Path to the Typst file
--- @return table|nil Parsed metadata or nil if not found
function M.parse_metadata(filepath)
  -- Check if typst binary is available
  if vim.fn.executable("typst") == 0 then
    return nil
  end

  -- Use typst query to extract metadata (disable color to avoid ANSI codes)
  local cmd = string.format('typst --color never query --format json "%s" metadata', filepath)
  local output = vim.fn.system(cmd)

  -- Check if command succeeded
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Extract JSON from output (handle case where shell outputs extra info)
  -- Look for JSON array pattern at the end
  local json_start = output:find('%[%{"func"')
  if json_start then
    output = output:sub(json_start)
  end

  -- Parse JSON output with robust fallback
  local result

  -- Try vim.json.decode first (modern API, available since Neovim 0.7+)
  if vim.json and vim.json.decode then
    local success
    success, result = pcall(vim.json.decode, output)
    if not success then
      result = nil
    end
  end

  -- Fallback to vim.fn.json_decode if needed
  if not result and vim.fn and vim.fn.json_decode then
    local success
    success, result = pcall(vim.fn.json_decode, output)
    if not success then
      result = nil
    end
  end

  -- Handle parsing failure or invalid result
  if not result or type(result) ~= "table" then
    return nil
  end

  -- Extract the first metadata entry if it exists
  -- Typst query returns: [{"func":"metadata","value":{...}}]
  if #result > 0 and result[1] and result[1].value then
    return result[1].value
  end

  return nil
end

--- Extract document title from metadata or content
--- @param filepath string Path to the Typst file
--- @return string Document title
function M.get_document_title(filepath)
  local metadata = M.parse_metadata(filepath)

  if metadata and metadata.title then
    return metadata.title
  end

  -- Fallback: use filename
  return vim.fn.fnamemodify(filepath, ":t:r")
end

--- Get all metadata fields for a document
--- @param filepath string Path to the Typst file
--- @return table Metadata with fallbacks
function M.get_document_info(filepath)
  local metadata = M.parse_metadata(filepath) or {}

  return {
    title = metadata.title or vim.fn.fnamemodify(filepath, ":t:r"),
    type = metadata.type or "document",
    status = metadata.status or "draft",
    date = metadata.date or os.date("%Y-%m-%d"),
    tags = metadata.tags or {},
    filepath = filepath,
    filename = vim.fn.fnamemodify(filepath, ":t"),
  }
end

return M
