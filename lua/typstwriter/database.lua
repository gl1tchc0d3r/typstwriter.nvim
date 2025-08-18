--- Database module for typstwriter.nvim
--- Provides SQLite-based document indexing and search capabilities using CLI
local M = {}

local config = require("typstwriter.config")
local utils = require("typstwriter.utils")

-- Schema version for migrations
local SCHEMA_VERSION = 1

-- SQLite3 binary path (will be detected on init)
local sqlite3_bin = nil

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

--- Detect SQLite3 binary
--- @return string|nil Path to sqlite3 binary
local function detect_sqlite3()
  local candidates = { "sqlite3", "/usr/bin/sqlite3", "/usr/sbin/sqlite3", "/usr/local/bin/sqlite3" }

  for _, candidate in ipairs(candidates) do
    local result = vim.fn.system(string.format("which %s 2>/dev/null", candidate))
    if vim.v.shell_error == 0 and result:match("%S") then
      return result:gsub("%s+$", "") -- trim whitespace
    end
  end

  return nil
end

--- Execute SQLite command using temporary file approach
--- @param sql string SQL command to execute
--- @param db_path string|nil Database path (uses default if nil)
--- @return string|nil Output from sqlite3 command
--- @return boolean Success status
local function exec_sql(sql, db_path)
  if not sqlite3_bin then
    return nil, false
  end

  db_path = db_path or M.get_database_path()

  -- Create temporary file for complex SQL commands
  local temp_sql_file = vim.fn.tempname() .. ".sql"
  local file = io.open(temp_sql_file, "w")
  if not file then
    return nil, false
  end

  file:write(sql)
  file:close()

  -- Execute SQL using file input to avoid shell escaping issues
  local cmd = string.format('%s "%s" < "%s" 2>&1', sqlite3_bin, db_path, temp_sql_file)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  -- Clean up temporary file
  vim.fn.delete(temp_sql_file)

  return output, success
end

--- Execute SQLite query and return JSON results
--- @param sql string SQL query to execute
--- @param db_path string|nil Database path (uses default if nil)
--- @return table|nil Parsed results or nil on error
local function query_json(sql, db_path)
  local json_sql = ".mode json\n" .. sql
  local output, success = exec_sql(json_sql, db_path)

  if not success or not output then
    return nil
  end

  -- Parse JSON output
  local ok, result = pcall(vim.json.decode, output:gsub("^%s+", ""):gsub("%s+$", ""))
  if ok and type(result) == "table" then
    return result
  end

  return nil
end

--- Initialize database connection
--- @return boolean Success status
function M.init()
  if not M.is_enabled() then
    return false
  end

  -- Detect SQLite3 binary
  sqlite3_bin = detect_sqlite3()
  if not sqlite3_bin then
    utils.notify("SQLite3 binary not found. Database features disabled.", vim.log.levels.WARN)
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

  -- Create schema (this will create the database file if it doesn't exist)
  M.ensure_schema()

  -- Configure SQLite for better performance
  local pragmas = {
    "PRAGMA foreign_keys = ON",
    "PRAGMA journal_mode = WAL",
    "PRAGMA synchronous = NORMAL",
    "PRAGMA cache_size = 10000",
    "PRAGMA temp_store = memory",
  }

  for _, pragma in ipairs(pragmas) do
    local _, success = exec_sql(pragma)
    if not success then
      utils.notify("Failed to configure database: " .. pragma, vim.log.levels.WARN)
    end
  end

  utils.notify("Database initialized: " .. db_path, vim.log.levels.DEBUG)
  return true
end

--- Close database connection (no-op for CLI approach)
function M.close()
  -- No persistent connection to close in CLI approach
end

--- Get SQLite3 binary path
--- @return string|nil SQLite3 binary path
function M.get_sqlite3_bin()
  return sqlite3_bin
end

--- Create database schema
function M.ensure_schema()
  if not sqlite3_bin then
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
  if not sqlite3_bin then
    return false
  end

  local schema_sql = [[
CREATE TABLE IF NOT EXISTS schema_info (
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE IF NOT EXISTS documents (
  id INTEGER PRIMARY KEY,
  filepath TEXT UNIQUE NOT NULL,
  title TEXT,
  type TEXT,
  status TEXT,
  date TEXT,
  modified_time INTEGER,
  content_hash TEXT,
  content_preview TEXT,
  full_content TEXT,
  summary TEXT,
  topics TEXT,
  entities TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS document_chunks (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  chunk_index INTEGER,
  content TEXT,
  word_count INTEGER,
  chunk_type TEXT,
  summary TEXT,
  topics TEXT,
  entities TEXT,
  keywords TEXT,
  sentiment TEXT,
  heading TEXT,
  heading_level INTEGER,
  embedding BLOB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chunk_tags (
  id INTEGER PRIMARY KEY,
  chunk_id INTEGER,
  tag TEXT,
  confidence REAL DEFAULT 1.0,
  tag_type TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (chunk_id) REFERENCES document_chunks(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS document_links (
  id INTEGER PRIMARY KEY,
  source_id INTEGER,
  target_id INTEGER,
  link_text TEXT,
  source_chunk_id INTEGER,
  context_before TEXT,
  context_after TEXT,
  link_type TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (source_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (target_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (source_chunk_id) REFERENCES document_chunks(id) ON DELETE SET NULL
);

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

  local _, success = exec_sql(schema_sql)
  if not success then
    utils.notify("Failed to create database schema", vim.log.levels.ERROR)
    return false
  end

  utils.notify("Database schema created successfully", vim.log.levels.DEBUG)
  return true
end

--- Get current schema version
--- @return integer Schema version (0 if not found)
function M.get_schema_version()
  if not sqlite3_bin then
    return 0
  end

  local results = query_json("SELECT value FROM schema_info WHERE key = 'version'")
  if results and #results > 0 then
    return tonumber(results[1].value) or 0
  end

  return 0
end

--- Set schema version
--- @param version integer Schema version
function M.set_schema_version(version)
  if not sqlite3_bin then
    return false
  end

  local sql =
    string.format("INSERT OR REPLACE INTO schema_info (key, value) VALUES ('version', '%s')", tostring(version))
  local _, success = exec_sql(sql)
  return success
end

--- Migrate schema from old version to new version
--- @param from_version integer Current version
--- @param to_version integer Target version
function M.migrate_schema(from_version, to_version)
  utils.notify(
    string.format("Migrating database schema from v%d to v%d", from_version, to_version),
    vim.log.levels.INFO
  )

  -- Future migrations will go here
  -- For now, we only have version 1

  M.set_schema_version(to_version)
end

--- Test database connection
--- @return boolean Connection is working
function M.test_connection()
  if not sqlite3_bin then
    return false
  end

  local _, success = exec_sql("SELECT 1")
  return success
end

--- Get database statistics
--- @return table Database statistics
function M.get_stats()
  if not sqlite3_bin then
    return {}
  end

  local stats = {}

  -- Document count
  local results = query_json("SELECT COUNT(*) as count FROM documents")
  if results and #results > 0 then
    stats.document_count = results[1].count
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
  if not sqlite3_bin then
    return {}
  end

  return query_json(sql) or {}
end

--- Execute SQL query and return results
--- @param sql string SQL query
--- @return table|nil Results or nil on error
function M.query(sql)
  return query_json(sql)
end

--- Execute SQL command (no return value expected)
--- @param sql string SQL command
--- @return boolean Success status
function M.execute(sql)
  local _, success = exec_sql(sql)
  return success
end

return M
