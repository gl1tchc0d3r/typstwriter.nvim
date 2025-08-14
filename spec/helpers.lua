-- Test helpers for typstwriter.nvim
local helpers = {}

-- Mock vim global for testing
helpers.mock_vim = function()
  local mock = {
    fn = {
      expand = function(path)
        if path:match("^~/") then
          return "/tmp/test" .. path:sub(2)
        end
        return path
      end,
      isdirectory = function()
        return 1
      end,
      mkdir = function()
        return 1
      end,
      glob = function()
        return {}
      end,
      json_decode = function(str)
        -- Simple JSON parser for testing
        if str:match("^%[%s*{.*}%s*%]$") then
          return {{
            func = "metadata",
            value = {
              type = "test",
              title = "Test Document",
              date = "2024-01-15",
              status = "draft",
              tags = {"test"}
            }
          }}
        end
        return nil
      end,
      fnamemodify = function(path, modifier)
        if modifier == ":t:r" then
          return path:match("([^/]+)%.") or path
        end
        return path
      end,
      filereadable = function()
        return 1
      end,
      getftime = function()
        return os.time()
      end,
      getpid = function()
        return 12345
      end,
      executable = function()
        return 1
      end,
      system = function()
        return ""
      end,
      jobstart = function()
        return 1
      end,
      has = function(feature)
        -- Mock common vim features
        if feature == "nvim-0.5" or feature == "nvim" then
          return 1
        elseif feature == "unix" then
          return 1 -- Mock as unix system
        elseif feature == "mac" or feature == "win32" then
          return 0
        end
        return 0
      end,
      confirm = function(msg, choices, default)
        return default or 1
      end,
    },
    has = function(feature)
      -- Mock common vim features
      if feature == "nvim-0.5" or feature == "nvim" then
        return 1
      elseif feature == "unix" then
        return 1 -- Mock as unix system
      elseif feature == "mac" or feature == "win32" then
        return 0
      end
      return 0
    end,
    cmd = function(command)
      -- Mock vim commands
    end,
    api = {
      nvim_create_user_command = function() end,
      nvim_create_autocmd = function()
        return 1
      end,
      nvim_create_augroup = function()
        return 1
      end,
    },
    keymap = {
      set = function() end,
    },
    log = {
      levels = {
        INFO = 2,
        WARN = 3,
        ERROR = 4,
      },
    },
    notify = function() end,
    tbl_deep_extend = function(behavior, ...)
      local result = {}
      for _, tbl in ipairs({ ... }) do
        for k, v in pairs(tbl) do
          result[k] = v
        end
      end
      return result
    end,
    split = function(str, sep)
      local result = {}
      for part in str:gmatch("([^" .. sep .. "]+)") do
        table.insert(result, part)
      end
      return result
    end,
    ui = {
      select = function(items, opts, callback)
        if callback then
          callback(items[1])
        end
      end,
      input = function(opts, callback)
        if callback then
          callback("test")
        end
      end,
    },
    defer_fn = function(fn, delay)
      fn()
    end,
    v = { shell_error = 0 },
    json = {
      decode = function(str)
        -- Modern JSON decode for testing
        if str:match("^%[%s*{.*}%s*%]$") then
          return {{
            func = "metadata",
            value = {
              type = "test",
              title = "Test Document",
              date = "2024-01-15",
              status = "draft",
              tags = {"test"}
            }
          }}
        end
        return nil
      end
    },
  }

  -- Make vim global available
  _G.vim = mock
  return mock
end

-- Clean up after test
helpers.cleanup = function()
  _G.vim = nil
  package.loaded["typstwriter"] = nil
  package.loaded["typstwriter.config"] = nil
  package.loaded["typstwriter.utils"] = nil
  package.loaded["typstwriter.templates"] = nil
  package.loaded["typstwriter.compiler"] = nil
end

-- Create temporary test files
helpers.create_test_template = function(name, content)
  content = content
    or [[
// Test Template v2 - Metadata-driven

#metadata((
  type: "test",
  title: "Test Template",
  date: "2024-01-15",
  status: "draft",
  tags: ("test",),
))

#set document(title: "Test Template")
#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)

= Test Content
This is a test template using metadata.
]]
  -- In real tests, this would create actual files
  -- For now, we'll just return the content
  return content
end

return helpers
