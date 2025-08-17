--- Document discovery and management module for typstwriter.nvim
--- Provides database-backed document operations and search capabilities
local M = {}

local config = require("typstwriter.config")
local database = require("typstwriter.database")
local indexing = require("typstwriter.indexing")
local utils = require("typstwriter.utils")

--- Get all documents from database with rich metadata
--- @param opts table|nil Options table with sorting, filtering, etc.
--- @return table List of documents with metadata
function M.get_all_documents(opts)
  opts = opts or {}
  
  -- Ensure database is initialized
  if not database.is_enabled() then
    utils.notify("Database not enabled, falling back to basic document discovery", vim.log.levels.WARN)
    return M.get_documents_fallback()
  end
  
  local db_success = database.init()
  if not db_success then
    utils.notify("Database initialization failed, falling back to basic document discovery", vim.log.levels.WARN)
    return M.get_documents_fallback()
  end
  
  -- Get documents from database
  local documents = indexing.get_all_documents()
  
  -- If no documents in database, try to auto-index
  if #documents == 0 then
    utils.notify("No documents in database, running auto-index...", vim.log.levels.INFO)
    local success_count, failure_count = indexing.sync_filesystem()
    if success_count > 0 then
      documents = indexing.get_all_documents()
      utils.notify(string.format("Auto-indexed %d documents", success_count), vim.log.levels.INFO)
    end
  end
  
  -- Apply filtering if specified
  if opts.type then
    documents = vim.tbl_filter(function(doc) return doc.type == opts.type end, documents)
  end
  
  if opts.status then
    documents = vim.tbl_filter(function(doc) return doc.status == opts.status end, documents)
  end
  
  if opts.has_tag then
    documents = vim.tbl_filter(function(doc) 
      return doc.topics and vim.tbl_contains(doc.topics, opts.has_tag)
    end, documents)
  end
  
  -- Apply sorting
  local sort_field = opts.sort or "updated_at"
  local sort_desc = opts.desc ~= false -- Default to descending
  
  table.sort(documents, function(a, b)
    local val_a = a[sort_field] or ""
    local val_b = b[sort_field] or ""
    
    if sort_desc then
      return val_a > val_b
    else
      return val_a < val_b
    end
  end)
  
  return documents
end

--- Fallback document discovery using filesystem scanning
--- @return table List of documents with basic metadata
function M.get_documents_fallback()
  local notes_dir = config.get("notes_dir")
  local documents = {}

  if not utils.dir_exists(notes_dir) then
    utils.notify("Notes directory does not exist: " .. notes_dir, vim.log.levels.WARN)
    return documents
  end

  -- Find all .typ files recursively
  local typ_files = vim.fn.glob(notes_dir .. "/**/*.typ", false, true)

  local metadata_parser = require("typstwriter.metadata")
  
  for _, filepath in ipairs(typ_files) do
    local doc_metadata = metadata_parser.parse_metadata(filepath)
    if doc_metadata then
      -- Convert to database-like format for consistency
      local doc = {
        id = nil, -- No database ID in fallback mode
        filepath = filepath,
        title = doc_metadata.title or vim.fn.fnamemodify(filepath, ":t:r"),
        type = doc_metadata.type or "document",
        status = doc_metadata.status or "draft",
        date = doc_metadata.date or os.date("%Y-%m-%d"),
        modified_time = vim.fn.getftime(filepath),
        content_preview = nil, -- No preview in fallback mode
        topics = doc_metadata.topics or {},
        entities = doc_metadata.entities or {},
        created_at = nil,
        updated_at = nil,
        -- Add convenience fields for backward compatibility
        filename = vim.fn.fnamemodify(filepath, ":t"),
        basename = vim.fn.fnamemodify(filepath, ":t:r"),
        tags = doc_metadata.topics or {}, -- Alias for topics
      }
      table.insert(documents, doc)
    end
  end

  -- Sort by title by default
  table.sort(documents, function(a, b)
    return (a.title or a.filename):lower() < (b.title or b.filename):lower()
  end)

  return documents
end

--- Search documents by text query
--- @param query string Search query
--- @param opts table|nil Search options
--- @return table Matching documents
function M.search_documents(query, opts)
  opts = opts or {}
  
  if not query or query == "" then
    return M.get_all_documents(opts)
  end
  
  local documents = M.get_all_documents(opts)
  local results = {}
  local query_lower = query:lower()
  
  for _, doc in ipairs(documents) do
    local matches = false
    
    -- Search in title
    if doc.title and doc.title:lower():find(query_lower, 1, true) then
      matches = true
    end
    
    -- Search in content preview
    if not matches and doc.content_preview then
      if doc.content_preview:lower():find(query_lower, 1, true) then
        matches = true
      end
    end
    
    -- Search in topics/tags
    if not matches and doc.topics then
      for _, topic in ipairs(doc.topics) do
        if topic:lower():find(query_lower, 1, true) then
          matches = true
          break
        end
      end
    end
    
    -- Search in filepath
    if not matches then
      if doc.filepath:lower():find(query_lower, 1, true) then
        matches = true
      end
    end
    
    if matches then
      table.insert(results, doc)
    end
  end
  
  return results
end

--- Get documents by type
--- @param doc_type string Document type to filter by
--- @return table Documents of specified type
function M.get_documents_by_type(doc_type)
  return M.get_all_documents({ type = doc_type })
end

--- Get documents by status
--- @param status string Status to filter by
--- @return table Documents with specified status
function M.get_documents_by_status(status)
  return M.get_all_documents({ status = status })
end

--- Get documents with specific tag/topic
--- @param tag string Tag/topic to filter by
--- @return table Documents containing the tag
function M.get_documents_with_tag(tag)
  return M.get_all_documents({ has_tag = tag })
end

--- Find document by filepath
--- @param filepath string Path to document
--- @return table|nil Document metadata or nil if not found
function M.get_document_by_path(filepath)
  local documents = M.get_all_documents()
  
  for _, doc in ipairs(documents) do
    if doc.filepath == filepath then
      return doc
    end
  end
  
  return nil
end

--- Find document by title (fuzzy matching)
--- @param title string Document title to search for
--- @return table|nil Best matching document or nil
function M.get_document_by_title(title)
  local documents = M.get_all_documents()
  local title_lower = title:lower()
  
  -- First try exact match
  for _, doc in ipairs(documents) do
    if doc.title and doc.title:lower() == title_lower then
      return doc
    end
  end
  
  -- Then try fuzzy match
  for _, doc in ipairs(documents) do
    if doc.title and doc.title:lower():find(title_lower, 1, true) then
      return doc
    end
  end
  
  -- Finally try filename match
  for _, doc in ipairs(documents) do
    if doc.basename and doc.basename:lower():find(title_lower, 1, true) then
      return doc
    end
  end
  
  return nil
end

--- Format document for display in pickers
--- @param doc table Document metadata
--- @return string Formatted display string
function M.format_document_display(doc)
  local display_parts = {}

  -- Title (or filename if no title)
  local title = doc.title or doc.basename or doc.filename
  table.insert(display_parts, title)

  -- Status badge
  if doc.status and doc.status ~= "draft" then
    table.insert(display_parts, string.format("[%s]", doc.status:upper()))
  end

  -- Tags/Topics
  local tags = doc.topics or doc.tags or {}
  if #tags > 0 then
    table.insert(display_parts, string.format("#%s", table.concat(tags, " #")))
  end

  -- Document type
  if doc.type and doc.type ~= "document" then
    table.insert(display_parts, string.format("(%s)", doc.type))
  end
  
  -- Date indicator for recently modified
  if doc.updated_at then
    local days_ago = math.floor((os.time() - doc.updated_at) / 86400)
    if days_ago == 0 then
      table.insert(display_parts, "📝")
    elseif days_ago <= 7 then
      table.insert(display_parts, string.format("(%dd)", days_ago))
    end
  end

  return table.concat(display_parts, " ")
end

--- Get document statistics
--- @return table Statistics about documents in the database
function M.get_document_stats()
  local documents = M.get_all_documents()
  
  local stats = {
    total_count = #documents,
    by_type = {},
    by_status = {},
    recent_count = 0, -- Last 7 days
  }
  
  local now = os.time()
  local week_ago = now - (7 * 24 * 60 * 60)
  
  for _, doc in ipairs(documents) do
    -- Count by type
    local doc_type = doc.type or "document"
    stats.by_type[doc_type] = (stats.by_type[doc_type] or 0) + 1
    
    -- Count by status
    local status = doc.status or "draft"
    stats.by_status[status] = (stats.by_status[status] or 0) + 1
    
    -- Count recent documents
    if doc.updated_at and doc.updated_at >= week_ago then
      stats.recent_count = stats.recent_count + 1
    end
  end
  
  return stats
end

--- Refresh document index (sync with filesystem)
--- @return number, number Success count, failure count
function M.refresh_index()
  if not database.is_enabled() then
    utils.notify("Database not enabled, cannot refresh index", vim.log.levels.WARN)
    return 0, 0
  end
  
  utils.notify("Refreshing document index...", vim.log.levels.INFO)
  return indexing.sync_filesystem()
end

--- Rebuild entire document index
--- @return number, number Success count, failure count
function M.rebuild_index()
  if not database.is_enabled() then
    utils.notify("Database not enabled, cannot rebuild index", vim.log.levels.WARN)
    return 0, 0
  end
  
  utils.notify("Rebuilding document index...", vim.log.levels.INFO)
  return indexing.rebuild_index()
end

return M
