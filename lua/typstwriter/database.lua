--- Database module for typstwriter.nvim
--- Provides SQLite-based document indexing and search capabilities
local M = {}

local config = require("typstwriter.config")
local utils = require("typstwriter.utils")

-- Database connection (singleton)
local db = nil

-- Schema version for migrations
local SCHEMA_VERSION = 1

--- Get database file path
--- @return string Database file path
function M.get_database_path()
  local database_dir = config.get("database_dir")
  local filename = config.get("database.filename") or "typstwriter.db"
  return database_dir .. "/" .. filename
end

--- Get backup directory path
--- @return string Backup directory path
function M.get_backup_dir()
  local database_dir = config.get("database_dir")
  return database_dir .. "/backups"
end

--- Check if database is enabled in config
--- @return boolean
function M.is_enabled()
  return config.get("database.enabled") == true
end

--- Initialize database connection
--- @return boolean Success status
function M.init()
  if not M.is_enabled() then
    return false
  end

  -- Check if lsqlite3 is available
  local ok, sqlite3 = pcall(require, "lsqlite3")
  if not ok then
    utils.notify("SQLite3 Lua binding (lsqlite3) not found. Database features disabled.", vim.log.levels.WARN)
    return false
  end

  local db_path = M.get_database_path()
  
  -- Create database directory if needed
  local db_dir = vim.fn.fnamemodify(db_path, ":h")
  if vim.fn.isdirectory(db_dir) == 0 then
    local success = vim.fn.mkdir(db_dir, "p")
    if success == 0 then
      utils.notify("Failed to create database directory: " .. db_dir, vim.log.levels.ERROR)
      return false
    end
  end

  -- Open database connection
  db = sqlite3.open(db_path)
  if not db then
    utils.notify("Failed to open database: " .. db_path, vim.log.levels.ERROR)
    return false
  end

  -- Configure SQLite for better performance
  db:exec("PRAGMA foreign_keys = ON")
  db:exec("PRAGMA journal_mode = WAL")
  db:exec("PRAGMA synchronous = NORMAL")
  db:exec("PRAGMA cache_size = 10000")
  db:exec("PRAGMA temp_store = memory")

  -- Create schema if needed
  M.ensure_schema()

  utils.notify("Database initialized: " .. db_path, vim.log.levels.DEBUG)
  return true
end

--- Close database connection
function M.close()
  if db then
    db:close()
    db = nil
  end
end

--- Create database schema
function M.ensure_schema()
  if not db then
    return false
  end

  -- Check current schema version
  local version = M.get_schema_version()
  
  if version == 0 then
    -- Create fresh schema
    M.create_schema()
    M.set_schema_version(SCHEMA_VERSION)
  elseif version < SCHEMA_VERSION then
    -- Run migrations
    M.migrate_schema(version, SCHEMA_VERSION)
  end

  return true
end

--- Create initial database schema
function M.create_schema()
  if not db then
    return false
  end

  local schema_sql = [[
    -- Schema version tracking
    CREATE TABLE IF NOT EXISTS schema_info (
      key TEXT PRIMARY KEY,
      value TEXT
    );

    -- Documents table (document-level metadata)
    CREATE TABLE IF NOT EXISTS documents (
      id INTEGER PRIMARY KEY,
      filepath TEXT UNIQUE NOT NULL,
      title TEXT,
      type TEXT,
      status TEXT,
      date TEXT,
      modified_time INTEGER,
      content_hash TEXT,
      content_preview TEXT,      -- First 2000 chars for search
      full_content TEXT,         -- Complete content
      summary TEXT,              -- AI-generated document summary (Phase 4)
      topics TEXT,               -- JSON array: ["AI", "databases", "PKS"]
      entities TEXT,             -- JSON array: ["SQLite", "DuckDB", "Neovim"]
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Chunks table with rich semantic context
    CREATE TABLE IF NOT EXISTS document_chunks (
      id INTEGER PRIMARY KEY,
      document_id INTEGER,
      chunk_index INTEGER,
      content TEXT,
      word_count INTEGER,
      chunk_type TEXT,           -- 'section', 'paragraph', 'code_block', 'list'
      
      -- Semantic context per chunk
      summary TEXT,              -- "This chunk discusses database schema design"
      topics TEXT,               -- JSON: ["database", "schema", "SQLite"] 
      entities TEXT,             -- JSON: ["SQLite", "PRIMARY KEY", "FOREIGN KEY"]
      keywords TEXT,             -- JSON: ["indexing", "performance", "queries"]
      sentiment TEXT,            -- "neutral", "positive", "problem", "solution"
      
      -- Structural context
      heading TEXT,              -- Section heading this chunk belongs to
      heading_level INTEGER,     -- 1=main section, 2=subsection, etc.
      
      -- AI context (Phase 4)
      embedding BLOB,            -- Vector embedding for semantic search
      
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      
      FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
    );

    -- Flexible chunk tagging system
    CREATE TABLE IF NOT EXISTS chunk_tags (
      id INTEGER PRIMARY KEY,
      chunk_id INTEGER,
      tag TEXT,
      confidence REAL DEFAULT 1.0,   -- AI confidence or 1.0 for manual
      tag_type TEXT,                 -- 'topic', 'entity', 'keyword', 'manual'
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (chunk_id) REFERENCES document_chunks(id) ON DELETE CASCADE
    );

    -- Links with context and chunk reference
    CREATE TABLE IF NOT EXISTS document_links (
      id INTEGER PRIMARY KEY,
      source_id INTEGER,
      target_id INTEGER,
      link_text TEXT,
      source_chunk_id INTEGER,       -- Which chunk contains the link
      context_before TEXT,           -- 100 chars before link
      context_after TEXT,            -- 100 chars after link
      link_type TEXT,                -- 'reference', 'link', 'mention'
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (source_id) REFERENCES documents(id) ON DELETE CASCADE,
      FOREIGN KEY (target_id) REFERENCES documents(id) ON DELETE CASCADE,
      FOREIGN KEY (source_chunk_id) REFERENCES document_chunks(id) ON DELETE SET NULL
    );

    -- Indexes for performance
    CREATE INDEX IF NOT EXISTS idx_documents_filepath ON documents(filepath);
    CREATE INDEX IF NOT EXISTS idx_documents_type ON documents(type);
    CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
    CREATE INDEX IF NOT EXISTS idx_documents_modified ON documents(modified_time);
    CREATE INDEX IF NOT EXISTS idx_documents_content_preview ON documents(content_preview);
    CREATE INDEX IF NOT EXISTS idx_documents_title ON documents(title);

    CREATE INDEX IF NOT EXISTS idx_chunks_document ON document_chunks(document_id);
    CREATE INDEX IF NOT EXISTS idx_chunks_topics ON document_chunks(topics);
    CREATE INDEX IF NOT EXISTS idx_chunks_content ON document_chunks(content);
    CREATE INDEX IF NOT EXISTS idx_chunks_heading ON document_chunks(heading);

    CREATE INDEX IF NOT EXISTS idx_tags_chunk ON chunk_tags(chunk_id);
    CREATE INDEX IF NOT EXISTS idx_tags_tag ON chunk_tags(tag);
    CREATE INDEX IF NOT EXISTS idx_tags_type ON chunk_tags(tag_type);

    CREATE INDEX IF NOT EXISTS idx_links_source ON document_links(source_id);
    CREATE INDEX IF NOT EXISTS idx_links_target ON document_links(target_id);
    CREATE INDEX IF NOT EXISTS idx_links_source_chunk ON document_links(source_chunk_id);
  ]]

  local success = db:exec(schema_sql)
  if success ~= 0 then
    utils.notify("Failed to create database schema: " .. db:errmsg(), vim.log.levels.ERROR)
    return false
  end

  utils.notify("Database schema created successfully", vim.log.levels.DEBUG)
  return true
end

--- Get current schema version
--- @return integer Schema version (0 if not found)
function M.get_schema_version()
  if not db then
    return 0
  end

  local stmt = db:prepare("SELECT value FROM schema_info WHERE key = 'version'")
  if not stmt then
    return 0
  end

  local version = 0
  for row in stmt:nrows() do
    version = tonumber(row.value) or 0
  end
  stmt:finalize()
  
  return version
end

--- Set schema version
--- @param version integer Schema version
function M.set_schema_version(version)
  if not db then
    return false
  end

  local stmt = db:prepare("INSERT OR REPLACE INTO schema_info (key, value) VALUES ('version', ?)")
  if stmt then
    stmt:bind_values(tostring(version))
    stmt:step()
    stmt:finalize()
    return true
  end
  return false
end

--- Migrate schema from old version to new version
--- @param from_version integer Current version
--- @param to_version integer Target version  
function M.migrate_schema(from_version, to_version)
  utils.notify(string.format("Migrating database schema from v%d to v%d", from_version, to_version), vim.log.levels.INFO)
  
  -- Future migrations will go here
  -- For now, we only have version 1
  
  M.set_schema_version(to_version)
end

--- Test database connection
--- @return boolean Connection is working
function M.test_connection()
  if not db then
    return false
  end

  local stmt = db:prepare("SELECT 1")
  if stmt then
    local result = stmt:step()
    stmt:finalize()
    return result == 100  -- SQLITE_ROW
  end
  return false
end

--- Get database statistics
--- @return table Database statistics
function M.get_stats()
  if not db then
    return {}
  end

  local stats = {}
  
  -- Document count
  local stmt = db:prepare("SELECT COUNT(*) as count FROM documents")
  if stmt then
    for row in stmt:nrows() do
      stats.document_count = row.count
    end
    stmt:finalize()
  end

  -- Database file size
  local db_path = M.get_database_path()
  if vim.fn.filereadable(db_path) == 1 then
    stats.file_size = vim.fn.getfsize(db_path)
  end

  -- Schema version
  stats.schema_version = M.get_schema_version()

  return stats
end

--- Execute a raw SQL query (for debugging)
--- @param sql string SQL query
--- @return table Results
function M.execute_raw(sql)
  if not db then
    return {}
  end

  local results = {}
  local stmt = db:prepare(sql)
  
  if stmt then
    for row in stmt:nrows() do
      table.insert(results, row)
    end
    stmt:finalize()
  end

  return results
end

return M
