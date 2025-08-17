--- CLI command parser and router for typstwriter.nvim
--- Provides a unified command interface with subcommands
local utils = require("typstwriter.utils")
local M = {}

-- Command registry
local commands = {}

--- Register a command handler
--- @param path string Command path (e.g., "new", "templates.list")
--- @param handler function Command handler function
--- @param opts table|nil Command options (desc, complete, etc.)
function M.register_command(path, handler, opts)
  opts = opts or {}

  local parts = vim.split(path, ".", { plain = true })
  local current = commands

  -- Navigate to parent command
  for i = 1, #parts - 1 do
    local part = parts[i]
    if not current[part] then
      current[part] = {}
    end
    current = current[part]
  end

  -- Set the handler
  local final_key = parts[#parts]
  current[final_key] = {
    handler = handler,
    desc = opts.desc or "",
    complete = opts.complete,
  }
end

--- Get available subcommands at a given path
--- @param path string[] Command path parts
--- @return table Available subcommands
local function get_subcommands(path)
  local current = commands

  for _, part in ipairs(path) do
    if not current[part] or type(current[part]) ~= "table" then
      return {}
    end
    current = current[part]
  end

  local subcommands = {}
  for key, value in pairs(current) do
    if type(value) == "table" and (value.handler or next(value)) then
      table.insert(subcommands, key)
    end
  end

  return subcommands
end

--- Execute CLI command
--- @param opts table Command options from nvim_create_user_command
function M.execute(opts)
  local args = opts.fargs or {}

  if #args == 0 then
    M.show_help()
    return
  end

  -- Navigate to command handler
  local current = commands
  local path = {}

  for i, arg in ipairs(args) do
    table.insert(path, arg)

    if not current[arg] then
      utils.notify("Unknown command: " .. table.concat(path, " "), vim.log.levels.ERROR)
      return
    end

    current = current[arg]

    -- Check if this is a handler
    if type(current) == "table" and current.handler then
      local handler = current.handler
      -- Pass remaining args to handler
      local remaining_args = vim.list_slice(args, i + 1)
      handler(remaining_args, opts)
      return
    end
  end

  -- If we get here, the command path was incomplete
  local available = get_subcommands(path)
  if #available > 0 then
    utils.notify("Available subcommands: " .. table.concat(available, ", "), vim.log.levels.INFO)
  else
    utils.notify("Command not found: " .. table.concat(path, " "), vim.log.levels.ERROR)
  end
end

--- Tab completion for CLI commands
--- @param arg_lead string Current argument being completed
--- @param cmd_line string Full command line
--- @param cursor_pos number Cursor position
--- @return table Completion options
function M.complete(arg_lead, cmd_line, cursor_pos)
  -- Parse the command line to get current path
  local parts = vim.split(cmd_line, "%s+")
  table.remove(parts, 1) -- Remove ":TypstWriter"

  -- If we're completing the current argument, remove the incomplete part
  if arg_lead ~= "" then
    table.remove(parts)
  end

  local available = get_subcommands(parts)

  -- Filter by current input
  if arg_lead ~= "" then
    available = vim.tbl_filter(function(cmd)
      return cmd:find(arg_lead, 1, true) == 1
    end, available)
  end

  return available
end

--- Show help information
--- @param path string[]|nil Command path to show help for
function M.show_help(path)
  path = path or {}

  if #path == 0 then
    -- Show main help
    local help_lines = {
      "TypstWriter - Metadata-driven Typst writing system",
      "Usage: :TypstWriter <subcommand> [options] [arguments]",
      "",
      "📝 Document Operations:",
      "  new [template] [title]     Create new document from template",
      "  compile                    Compile current document to PDF",
      "  open                      Open PDF of current document", 
      "  both                      Compile and open PDF of current document",
      "",
      "🔍 Search & Discovery:",
      "  search [query]            Search documents (supports @tag, status:value, type:value)",
      "  recent [days]             Show recently modified documents (default: 7 days)",
      "  stats                     Show document statistics",
      "  refresh                   Refresh document index",
      "  rebuild                   Rebuild document index",
      "",
      "📋 Templates:",
      "  templates list            List available templates",
      "  templates copyexamples    Copy example templates to user directory",
      "",
      "📦 Package Management:",
      "  package status            Show package installation status",
      "  setup                     Complete system setup (install package + templates)",
      "  status                    Show system status",
      "",
      "💡 Examples:",
      "  :TypstWriter search @meeting         # Find documents tagged 'meeting'",
      "  :TypstWriter search status:draft     # Find draft documents",
      "  :TypstWriter search project report  # Search for 'project report' in content",
      "  :TypstWriter recent 14              # Show documents from last 14 days",
      "",
      "Use ':TypstWriter help <command>' for detailed help on specific commands",
    }
    
    utils.show_in_float("TypstWriter Help", help_lines)
  else
    -- Show specific command help
    local help_text = { "Help for: " .. table.concat(path, " "), "", "TODO: Add detailed help for specific commands" }
    utils.show_in_float("Command Help", help_text)
  end
end

--- Initialize CLI commands
function M.setup()
  -- Document operations
  M.register_command("new", function(args, opts)
    require("typstwriter.templates").create_from_template()
  end, { desc = "Create new document from template" })

  M.register_command("compile", function(args, opts)
    require("typstwriter.document").compile_current()
  end, { desc = "Compile current document to PDF" })

  M.register_command("open", function(args, opts)
    require("typstwriter.document").open_pdf()
  end, { desc = "Open PDF of current document" })

  M.register_command("both", function(args, opts)
    require("typstwriter.document").compile_and_open()
  end, { desc = "Compile and open PDF" })

  -- Template operations
  M.register_command("templates.list", function(args, opts)
    require("typstwriter.templates").show_templates()
  end, { desc = "List available templates" })

  -- Package operations
  M.register_command("package.status", function(args, opts)
    require("typstwriter.package").show_status()
  end, { desc = "Show package installation status" })

  M.register_command("package.install", function(args, opts)
    require("typstwriter.package").install_package()
  end, { desc = "Install typstwriter package" })

  M.register_command("templates.copyexamples", function(args, opts)
    local success, message = require("typstwriter.templates").install_templates()
    if success then
      utils.notify(message, vim.log.levels.INFO)
    else
      utils.notify(message, vim.log.levels.ERROR)
    end
  end, { desc = "Copy example templates to user directory" })

  -- System operations
  M.register_command("setup", function(args, opts)
    require("typstwriter.package").setup()
  end, { desc = "Complete system setup" })

  M.register_command("status", function(args, opts)
    require("typstwriter.document").show_status()
  end, { desc = "Show system status and metadata info" })

  -- Document search and discovery (database-backed)
  M.register_command("search", function(args, opts)
    local search = require("typstwriter.search")
    local query = table.concat(args, " ")
    if query == "" then
      utils.input({ prompt = "Search documents: " }, function(input_query)
        if input_query and input_query ~= "" then
          M.execute_search(input_query)
        end
      end)
    else
      M.execute_search(query)
    end
  end, { desc = "Search documents by content, tags, or metadata" })
  
  M.register_command("recent", function(args, opts)
    local search = require("typstwriter.search")
    local days = tonumber(args[1]) or 7
    local recent_docs = search.get_all_documents({ sort = "updated_at", desc = true })
    -- Filter to recent documents
    local cutoff_time = os.time() - (days * 24 * 60 * 60)
    local filtered = vim.tbl_filter(function(doc)
      return doc.updated_at and doc.updated_at >= cutoff_time
    end, recent_docs)
    M.show_document_results(filtered, string.format("Recent (%d days)", days))
  end, { desc = "Show recently modified documents" })
  
  M.register_command("stats", function(args, opts)
    M.show_document_stats()
  end, { desc = "Show document statistics" })
  
  M.register_command("refresh", function(args, opts)
    local search = require("typstwriter.search")
    utils.notify("Refreshing document index...", vim.log.levels.INFO)
    local success_count, failure_count = search.refresh_index()
    if success_count > 0 or failure_count > 0 then
      utils.notify(
        string.format("Index refresh: %d updates, %d failures", success_count, failure_count),
        vim.log.levels.INFO
      )
    else
      utils.notify("Index is up to date", vim.log.levels.INFO)
    end
  end, { desc = "Refresh document index" })
  
  M.register_command("rebuild", function(args, opts)
    local confirm = vim.fn.confirm("Rebuild entire document index?", "&Yes\n&No", 2)
    if confirm ~= 1 then
      return
    end
    local search = require("typstwriter.search")
    utils.notify("Rebuilding document index...", vim.log.levels.INFO)
    local success_count, failure_count = search.rebuild_index()
    utils.notify(
      string.format("Index rebuild: %d successful, %d failed", success_count, failure_count),
      success_count > 0 and vim.log.levels.INFO or vim.log.levels.WARN
    )
  end, { desc = "Rebuild document index" })

  -- Help command
  M.register_command("help", function(args, opts)
    M.show_help(args)
  end, { desc = "Show help information" })
end

--- Execute search with query parsing
--- @param query string Search query with special syntax
function M.execute_search(query)
  local search = require("typstwriter.search")
  
  -- Parse query for special syntax
  local search_opts = {}
  local search_terms = {}
  
  -- Parse @tag syntax
  for tag in query:gmatch("@(%w+)") do
    search_opts.has_tag = tag
  end
  
  -- Parse status:value syntax  
  local status_match = query:match("status:(%w+)")
  if status_match then
    search_opts.status = status_match
  end
  
  -- Parse type:value syntax
  local type_match = query:match("type:(%w+)")
  if type_match then
    search_opts.type = type_match
  end
  
  -- Extract remaining terms for text search
  local text_query = query
    :gsub("@%w+", "") -- Remove @tag
    :gsub("status:%w+", "") -- Remove status:value
    :gsub("type:%w+", "") -- Remove type:value
    :gsub("%s+", " ") -- Clean up spaces
    :match("^%s*(.-)%s*$") -- Trim
  
  -- Perform search
  local results
  if text_query and text_query ~= "" then
    results = search.search_documents(text_query, search_opts)
  else
    results = search.get_all_documents(search_opts)
  end
  
  if #results == 0 then
    utils.notify(string.format("No documents found for query: %s", query), vim.log.levels.WARN)
    return
  end
  
  M.show_document_results(results, string.format("Search: %s", query))
end

--- Show document search results in a picker
--- @param docs table List of documents
--- @param title string Title for the picker
function M.show_document_results(docs, title)
  if #docs == 0 then
    utils.notify("No documents to show", vim.log.levels.WARN)
    return
  end
  
  if #docs == 1 then
    -- Single result, open directly
    M.open_document(docs[1])
    return
  end
  
  -- Multiple results, show picker
  local search = require("typstwriter.search")
  local choices = {}
  local doc_map = {}
  
  for _, doc in ipairs(docs) do
    local display = search.format_document_display(doc)
    table.insert(choices, display)
    doc_map[display] = doc
  end
  
  utils.select(choices, {
    prompt = title or "Select document:",
    format_item = function(item) return item end,
  }, function(choice)
    if choice and doc_map[choice] then
      M.open_document(doc_map[choice])
    end
  end)
end

--- Open a document in Neovim
--- @param doc table Document metadata
function M.open_document(doc)
  if not doc or not doc.filepath then
    utils.notify("Invalid document", vim.log.levels.ERROR)
    return
  end
  
  -- Check if file exists
  if vim.fn.filereadable(doc.filepath) == 0 then
    utils.notify("Document file not found: " .. doc.filepath, vim.log.levels.ERROR)
    return
  end
  
  -- Open the document
  vim.cmd("edit " .. vim.fn.fnameescape(doc.filepath))
  utils.notify("Opened: " .. (doc.title or doc.filename), vim.log.levels.INFO)
end

--- Show document statistics
function M.show_document_stats()
  local search = require("typstwriter.search")
  local stats = search.get_document_stats()
  
  local lines = {
    "📊 Document Statistics",
    "═══════════════════",
    string.format("Total documents: %d", stats.total_count),
    string.format("Recent documents (7 days): %d", stats.recent_count),
    "",
    "📁 By Type:",
    "─────────",
  }
  
  for doc_type, count in pairs(stats.by_type) do
    table.insert(lines, string.format("  %-20s %d", doc_type, count))
  end
  
  table.insert(lines, "")
  table.insert(lines, "📋 By Status:")
  table.insert(lines, "──────────")
  
  for status, count in pairs(stats.by_status) do
    table.insert(lines, string.format("  %-20s %d", status, count))
  end
  
  -- Show using the floating window utility
  utils.show_in_float("Document Statistics", lines)
end

return M
