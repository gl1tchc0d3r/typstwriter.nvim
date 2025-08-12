local helpers = require("helpers")

describe("typstwriter compiler", function()
  local compiler

  before_each(function()
    helpers.mock_vim()

    -- Mock the config module
    package.loaded["typstwriter.config"] = {
      get = function(key)
        if key == "auto_compile" then
          return false
        end
        if key == "open_after_compile" then
          return false
        end
        if key == "notifications" then
          return true
        end
        return nil
      end,
      should_notify = function()
        return true
      end,
      get_notification_level = function()
        return vim.log.levels.INFO
      end,
    }

    compiler = require("typstwriter.compiler")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("compile_current", function()
    it("should compile typst file to PDF", function()
      local system_commands = {}

      -- Mock vim.fn.system
      vim.fn.system = function(cmd)
        table.insert(system_commands, cmd)
        return "Success"
      end

      -- Mock vim.v.shell_error
      vim.v.shell_error = 0

      -- Mock file functions
      vim.fn.expand = function(pattern)
        if pattern == "%:e" then
          return "typ"
        end
        if pattern == "%:p" then
          return "/tmp/test.typ"
        end
        return pattern
      end

      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.executable = function()
        return 1
      end

      local success = compiler.compile_current("/tmp/test.typ")

      assert.is_true(success)
      assert.equals(1, #system_commands)
      assert.is_not_nil(system_commands[1]:match("typst compile.*test.typ"))
    end)

    it("should handle compilation errors", function()
      local error_messages = {}

      -- Mock vim.fn.system to fail
      vim.fn.system = function(cmd)
        return "Error: syntax error on line 10"
      end

      -- Mock vim.v.shell_error to indicate failure
      vim.v.shell_error = 1

      -- Suppress print output during test
      local original_print = _G.print
      _G.print = function() end

      vim.notify = function(msg, level)
        if level >= vim.log.levels.ERROR then
          table.insert(error_messages, msg)
        end
      end

      -- Mock other required functions
      vim.fn.expand = function(pattern)
        if pattern == "%:e" then
          return "typ"
        end
        if pattern == "%:p" then
          return "/tmp/test.typ"
        end
        return pattern
      end

      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.executable = function()
        return 1
      end

      local success = compiler.compile_current("/tmp/test.typ")

      -- Restore original print function
      _G.print = original_print

      assert.is_false(success)
      assert.equals(1, #error_messages)
    end)

    it("should reject non-typst files", function()
      local error_messages = {}

      vim.notify = function(msg, level)
        if level >= vim.log.levels.WARN then
          table.insert(error_messages, msg)
        end
      end

      -- Mock file functions to return non-typ extension
      vim.fn.expand = function(pattern)
        if pattern == "%:e" then
          return "txt"
        end
        if pattern == "%:p" then
          return "/tmp/test.txt"
        end
        return pattern
      end

      local success = compiler.compile_current("/tmp/test.txt")

      assert.is_false(success)
      assert.equals(1, #error_messages)
      assert.is_not_nil(error_messages[1]:match("Not a Typst file"))
    end)
  end)
end)
