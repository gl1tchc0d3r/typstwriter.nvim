--- Document linking system for typstwriter.nvim
--- Provides interactive document linking with fuzzy search capabilities
local config = require("typstwriter.config")
local utils = require("typstwriter.utils")
local M = {}

--- Parse document metadata from Typst file
--- @param filepath string Path to the document
--- @return table|nil Document metadata
local function parse_document_metadata(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  
  local content = file:read("*all")
  file:close()
  
  local metadata = {
    title = nil,
    status = nil,
    tags = {},
    doc_type = nil,
    path = filepath,
    filename = vim.fn.fnamemodify(filepath, ":t"),
    basename = vim.fn.fnamemodify(filepath, ":t:r"),
  }
  
  -- Extract title from base.with() call
  local title_match = content:match('title:%s*"([^"]*)"') or content:match("title:%s*'([^']*)'")
  if title_match then
    metadata.title = title_match
  end
  
  -- Extract status
  local status_match = content:match('status:%s*"([^"]*)"') or content:match("status:%s*'([^']*)'")
  if status_match then
    metadata.status = status_match
  end
  
  -- Extract doc_type
  local doc_type_match = content:match('doc_type:%s*"([^"]*)"') or content:match("doc_type:%s*'([^']*)'")
  if doc_type_match then
    metadata.doc_type = doc_type_match
  end
  
  -- Extract tags from tags: (tag1, tag2, tag3) format
  local tags_match = content:match('tags:%s*%(([^)]*)%)')
  if tags_match then
    -- Split by comma and clean up quotes
    for tag in tags_match:gmatch('[^,]+') do
      tag = tag:match('^%s*"?\'?([^"\']*)"?\'?%s*$') -- Remove quotes and whitespace
      if tag and tag ~= "" then
        table.insert(metadata.tags, tag)
      end
    end
  end
  
  -- Fallback: use filename as title if no title found
  if not metadata.title or metadata.title == "" then
    metadata.title = metadata.basename:gsub("%.%w+$", "") -- Remove extension
  end
  
  return metadata
end

--- Get all documents in the notes directory
--- @return table List of document metadata
function M.get_all_documents()
  local notes_dir = config.get("notes_dir")
  local documents = {}
  
  if not utils.dir_exists(notes_dir) then
    utils.notify("Notes directory does not exist: " .. notes_dir, vim.log.levels.WARN)
    return documents
  end
  
  -- Find all .typ files recursively
  local typ_files = vim.fn.glob(notes_dir .. "/**/*.typ", false, true)
  
  for _, filepath in ipairs(typ_files) do
    local metadata = parse_document_metadata(filepath)
    if metadata then
      table.insert(documents, metadata)
    end
  end
  
  -- Sort by title
  table.sort(documents, function(a, b)
    return (a.title or a.filename):lower() < (b.title or b.filename):lower()
  end)
  
  return documents
end

--- Format document for display in picker
--- @param doc table Document metadata
--- @return string Formatted display string
local function format_document_display(doc)
  local display_parts = {}
  
  -- Title (or filename if no title)
  local title = doc.title or doc.basename
  table.insert(display_parts, title)
  
  -- Status badge
  if doc.status then
    table.insert(display_parts, string.format("[%s]", doc.status:upper()))
  end
  
  -- Tags
  if #doc.tags > 0 then
    table.insert(display_parts, string.format("#%s", table.concat(doc.tags, " #")))
  end
  
  -- Document type
  if doc.doc_type then
    table.insert(display_parts, string.format("(%s)", doc.doc_type))
  end
  
  return table.concat(display_parts, " ")
end

--- Generate link text for insertion
--- @param doc table Document metadata
--- @param format string Link format ("wiki" or "typst")
--- @return string Link text
local function generate_link_text(doc, format)
  format = format or "wiki" -- Default to wiki-style links
  
  local title = doc.title or doc.basename
  
  if format == "wiki" then
    return string.format("[[%s]]", title)
  elseif format == "typst" then
    -- Calculate relative path from current file to target
    local current_file = vim.fn.expand("%:p")
    local relative_path = vim.fn.fnamemodify(doc.path, ":.")
    
    -- Try to make a proper relative path
    if current_file and current_file ~= "" then
      local current_dir = vim.fn.fnamemodify(current_file, ":h")
      local target_dir = vim.fn.fnamemodify(doc.path, ":h") 
      
      -- If both are in notes_dir, calculate relative path
      local notes_dir = config.get("notes_dir")
      if vim.startswith(current_dir, notes_dir) and vim.startswith(target_dir, notes_dir) then
        relative_path = vim.fn.fnamemodify(doc.path, ":~:.")
      end
    end
    
    return string.format('#link("%s")[%s]', relative_path, title)
  end
  
  return title
end

--- Insert link at cursor position
--- @param link_text string The link text to insert
local function insert_link(link_text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  
  -- Insert the link at cursor position
  local new_line = current_line:sub(1, col) .. link_text .. current_line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
  
  -- Move cursor to end of inserted link
  vim.api.nvim_win_set_cursor(0, {row, col + #link_text})
end

--- Interactive document picker
--- @param callback function Callback function called with selected document
function M.pick_document(callback)
  local documents = M.get_all_documents()
  
  if #documents == 0 then
    utils.notify("No documents found in " .. config.get("notes_dir"), vim.log.levels.WARN)
    return
  end
  
  -- Prepare choices for picker
  local choices = {}
  local doc_map = {}
  
  for i, doc in ipairs(documents) do
    local display = format_document_display(doc)
    table.insert(choices, display)
    doc_map[display] = doc
  end
  
  -- Use vim.ui.select for the picker
  utils.select(choices, {
    prompt = "Select document to link:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice and doc_map[choice] then
      callback(doc_map[choice])
    end
  end)
end

--- Create link to document (interactive)
--- @param link_format string|nil Link format ("wiki" or "typst"), defaults to "wiki"
function M.create_link(link_format)
  link_format = link_format or "wiki"
  
  M.pick_document(function(doc)
    local link_text = generate_link_text(doc, link_format)
    insert_link(link_text)
    utils.notify("Linked to: " .. (doc.title or doc.filename))
  end)
end

--- Create link to specific document by name
--- @param document_name string Name or title of the document
--- @param link_format string|nil Link format ("wiki" or "typst"), defaults to "wiki"
function M.create_link_by_name(document_name, link_format)
  link_format = link_format or "wiki"
  
  local documents = M.get_all_documents()
  local found_doc = nil
  
  -- Search for document by title or filename
  for _, doc in ipairs(documents) do
    if (doc.title and doc.title:lower() == document_name:lower()) or 
       (doc.basename:lower() == document_name:lower()) or
       (doc.filename:lower() == document_name:lower()) then
      found_doc = doc
      break
    end
  end
  
  if found_doc then
    local link_text = generate_link_text(found_doc, link_format)
    insert_link(link_text)
    utils.notify("Linked to: " .. (found_doc.title or found_doc.filename))
  else
    -- Offer to create new document
    local confirm = vim.fn.confirm(
      string.format('Document "%s" not found. Create new document?', document_name),
      "&Yes\n&No", 
      1
    )
    
    if confirm == 1 then
      -- Create new document using templates module
      local templates = require("typstwriter.templates")
      templates.create_document("example", document_name)
      
      -- Insert link anyway (assuming document will be created)
      local link_text = link_format == "wiki" and 
        string.format("[[%s]]", document_name) or
        string.format('#link("%s.typ")[%s]', document_name, document_name)
      insert_link(link_text)
      utils.notify("Created link to new document: " .. document_name)
    end
  end
end

return M
