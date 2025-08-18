--- Document indexing module for typstwriter.nvim
--- Handles extracting metadata, content, and populating the database
local M = {}

local config = require("typstwriter.config")
local database = require("typstwriter.database")
local metadata = require("typstwriter.metadata")
local utils = require("typstwriter.utils")

--- Generate content hash for change detection
--- @param content string Full document content
--- @return string SHA256 hash
local function generate_content_hash(content)
  -- Simple hash using Lua's built-in string hashing
  -- In production, might want to use a proper hash function
  return tostring(content:len()) .. "_" .. tostring(content:sub(1, 100):byte(1, -1))
end

--- Extract content preview from full content
--- @param content string Full document content
--- @param max_chars number Maximum characters for preview
--- @return string Content preview
local function extract_content_preview(content, max_chars)
  max_chars = max_chars or 2000
  if #content <= max_chars then
    return content
  end

  -- Try to break at word boundary
  local preview = content:sub(1, max_chars)
  local last_space = preview:find(" [^ ]*$")
  if last_space then
    preview = preview:sub(1, last_space - 1) .. "..."
  else
    preview = preview .. "..."
  end

  return preview
end

--- Check if document needs reindexing
--- @param filepath string Path to document
--- @return boolean True if reindexing is needed
function M.needs_reindex(filepath)
  if not database.is_enabled() then
    return true -- No database, need to index
  end

  local file_mtime = vim.fn.getftime(filepath)
  if file_mtime <= 0 then
    return false -- File doesn't exist
  end

  -- Use CLI database query
  local sql = string.format(
    "SELECT modified_time, content_hash FROM documents WHERE filepath = '%s'",
    filepath:gsub("'", "''") -- Escape single quotes
  )

  local results = database.query(sql)
  if not results or #results == 0 then
    return true -- Document not in database
  end

  local doc_record = results[1]
  local db_mtime = tonumber(doc_record.modified_time)
  local db_hash = doc_record.content_hash

  if not db_mtime then
    return true -- Invalid database record
  end

  if file_mtime > db_mtime then
    return true -- File is newer than database record
  end

  -- Double-check with content hash for edge cases
  local success, content = pcall(function()
    local file = io.open(filepath, "r")
    if not file then
      return nil
    end
    local data = file:read("*all")
    file:close()
    return data
  end)

  if success and content then
    local current_hash = generate_content_hash(content)
    if current_hash ~= db_hash then
      return true -- Content changed without mtime update
    end
  end

  return false -- Document is up to date
end

--- Index a single document
--- @param filepath string Path to document file
--- @return boolean, string Success status and error message if failed
function M.index_document(filepath)
  if not database.is_enabled() then
    return false, "Database not enabled"
  end

  -- Check if file exists
  if vim.fn.filereadable(filepath) == 0 then
    return false, "File not readable: " .. filepath
  end

  -- Get database connection (initialize if needed)
  local db_success = database.init()
  if not db_success then
    return false, "Failed to initialize database"
  end

  -- Check if reindexing is needed
  if not M.needs_reindex(filepath) then
    return true, "Document is up to date"
  end

  -- Read file content
  local file = io.open(filepath, "r")
  if not file then
    return false, "Cannot open file: " .. filepath
  end

  local content = file:read("*all")
  file:close()

  if not content then
    return false, "Cannot read file content: " .. filepath
  end

  -- Extract metadata using existing metadata system
  local doc_metadata = metadata.parse_metadata(filepath)
  if not doc_metadata then
    utils.notify("No metadata found in " .. filepath .. ", using defaults", vim.log.levels.DEBUG)
    doc_metadata = {}
  end

  -- Generate content hash and preview
  local content_hash = generate_content_hash(content)
  local content_preview = extract_content_preview(content)
  local file_mtime = vim.fn.getftime(filepath)

  -- Prepare document data
  local doc_data = {
    filepath = filepath,
    title = doc_metadata.title or vim.fn.fnamemodify(filepath, ":t:r"),
    type = doc_metadata.type or "document",
    status = doc_metadata.status or "draft",
    date = doc_metadata.date or os.date("%Y-%m-%d"),
    modified_time = file_mtime,
    content_hash = content_hash,
    content_preview = content_preview,
    full_content = content,
    summary = nil, -- AI-generated summary (Phase 4)
    topics = doc_metadata.topics and vim.json.encode(doc_metadata.topics) or nil,
    entities = doc_metadata.entities and vim.json.encode(doc_metadata.entities) or nil,
  }

  -- Insert or update document in database
  local success, err = M.upsert_document(doc_data)
  if not success then
    return false, "Database upsert failed: " .. (err or "unknown error")
  end

  utils.notify("Indexed document: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.DEBUG)
  return true, "Document indexed successfully"
end

--- Insert or update document in database
--- @param doc_data table Document data
--- @return boolean, string Success status and error message
function M.upsert_document(doc_data)
  if not database.is_enabled() then
    return false, "Database not enabled"
  end

  -- Escape string values for SQL
  local function escape_sql(value)
    if value == nil then
      return "NULL"
    end
    return "'" .. tostring(value):gsub("'", "''") .. "'"
  end

  local sql = string.format(
    [[
    INSERT OR REPLACE INTO documents (
      filepath, title, type, status, date, modified_time,
      content_hash, content_preview, full_content, summary, topics, entities,
      updated_at
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
  ]],
    escape_sql(doc_data.filepath),
    escape_sql(doc_data.title),
    escape_sql(doc_data.type),
    escape_sql(doc_data.status),
    escape_sql(doc_data.date),
    escape_sql(doc_data.modified_time),
    escape_sql(doc_data.content_hash),
    escape_sql(doc_data.content_preview),
    escape_sql(doc_data.full_content),
    escape_sql(doc_data.summary),
    escape_sql(doc_data.topics),
    escape_sql(doc_data.entities)
  )

  local success = database.execute(sql)
  if not success then
    return false, "Failed to insert/update document"
  end

  return true
end

--- Get all documents from database
--- @return table List of documents with metadata
function M.get_all_documents()
  if not database.is_enabled() then
    return {}
  end

  local sql = [[
    SELECT id, filepath, title, type, status, date, modified_time,
           content_preview, topics, entities, created_at, updated_at
    FROM documents
    ORDER BY updated_at DESC
  ]]

  local results = database.query(sql)
  if not results then
    return {}
  end

  local documents = {}
  for _, row in ipairs(results) do
    -- Parse JSON fields
    row.topics = row.topics and vim.json.decode(row.topics) or {}
    row.entities = row.entities and vim.json.decode(row.entities) or {}
    table.insert(documents, row)
  end

  return documents
end

--- Rebuild entire index by scanning notes directory
--- @return number, number Number of successful indexes, number of failures
function M.rebuild_index()
  if not database.is_enabled() then
    utils.notify("Database not enabled", vim.log.levels.WARN)
    return 0, 0
  end

  local notes_dir = config.get("notes_dir")
  if not notes_dir or vim.fn.isdirectory(notes_dir) == 0 then
    utils.notify("Notes directory not found: " .. (notes_dir or "nil"), vim.log.levels.ERROR)
    return 0, 0
  end

  utils.notify("Rebuilding document index...", vim.log.levels.INFO)

  -- Find all .typ files in notes directory
  local typ_files = vim.fn.glob(notes_dir .. "/**/*.typ", false, true)

  local success_count = 0
  local failure_count = 0

  for _, filepath in ipairs(typ_files) do
    local success, err = M.index_document(filepath)
    if success then
      success_count = success_count + 1
    else
      failure_count = failure_count + 1
      utils.notify("Failed to index " .. filepath .. ": " .. err, vim.log.levels.WARN)
    end
  end

  utils.notify(
    string.format("Index rebuild complete: %d successful, %d failed", success_count, failure_count),
    vim.log.levels.INFO
  )

  return success_count, failure_count
end

--- Sync filesystem with database (incremental update)
--- @return number, number Number of updates, number of failures
function M.sync_filesystem()
  if not database.is_enabled() then
    return 0, 0
  end

  local notes_dir = config.get("notes_dir")
  if not notes_dir or vim.fn.isdirectory(notes_dir) == 0 then
    return 0, 0
  end

  -- Find all .typ files
  local typ_files = vim.fn.glob(notes_dir .. "/**/*.typ", false, true)

  local update_count = 0
  local failure_count = 0

  for _, filepath in ipairs(typ_files) do
    local success, err = M.index_document(filepath)
    if success and err ~= "Document is up to date" then
      update_count = update_count + 1
    elseif not success then
      failure_count = failure_count + 1
    end
  end

  -- TODO: Remove documents that no longer exist on filesystem
  -- This would require tracking which files we've seen

  if update_count > 0 or failure_count > 0 then
    utils.notify(
      string.format("Filesystem sync: %d updates, %d failures", update_count, failure_count),
      vim.log.levels.INFO
    )
  end

  return update_count, failure_count
end

--- Remove document from database
--- @param filepath string Path to document
--- @return boolean Success status
function M.remove_document(filepath)
  if not database.is_enabled() then
    return false
  end

  local sql = string.format("DELETE FROM documents WHERE filepath = '%s'", filepath:gsub("'", "''"))

  return database.execute(sql)
end

return M
