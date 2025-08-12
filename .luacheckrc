-- Luacheck configuration for typstwriter.nvim

-- Use LuaJIT standard library (includes table, os, ipairs, pairs, etc.)
std = "luajit"

-- Global variables that should be allowed in all files
globals = {
  "vim",
}

-- Read-only globals (Neovim API and Lua builtins)
read_globals = {
  "vim",
  -- Lua builtins that might not be in std
  "require",
  "table",
  "os",
  "ipairs",
  "pairs",
  "select",
  "_G",
  "package",
}

-- Exclude certain patterns from linting
exclude_files = {
  "lua/typstwriter/templates/defaults.lua",  -- Generated content
}

-- Test files configuration
files["spec/**/*.lua"] = {
  std = "busted+luajit",
  globals = {
    -- Busted test framework globals
    "setup",
    "teardown",
    "before_each",
    "after_each",
    "describe",
    "context",
    "it",
    "pending",
    "assert",
    "spy",
    "stub",
    "mock",
    -- Allow modification of globals in test files
    "vim",
    "_G",
    "package",
  },
  -- Allow unused variables in tests (test fixtures, etc.)
  unused = false,
}

-- Helper files configuration
files["spec/helpers.lua"] = {
  std = "luajit",
  globals = {
    "vim",
    "_G",
    "package",
    "require",
    "table",
    "os",
    "ipairs",
    "pairs",
  },
  -- Allow mutation of globals in helper files
  allow_defined_top = true,
}

-- Maximum line length
max_line_length = 120

-- Ignore certain warnings globally
ignore = {
  "212",  -- Unused argument (common in callbacks)
  "213",  -- Unused loop variable
  "122",  -- Setting read-only field (needed for vim mocking)
}
