local helpers = require("helpers")

describe("typstwriter integration", function()
  local typstwriter

  before_each(function()
    helpers.mock_vim()
    typstwriter = require("typstwriter")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("plugin setup", function()
    it("should setup without errors", function()
      -- Mock vim.fn.has for PDF opener detection
      vim.fn.has = function(feature)
        if feature == "unix" then
          return 1
        end
        return 0
      end

      assert.has_no_errors(function()
        typstwriter.setup({
          notes_dir = "~/test-notes",
          auto_compile = false,
        })
      end)
    end)

    it("should create user commands", function()
      local commands_created = {}

      vim.api.nvim_create_user_command = function(name, fn, opts)
        commands_created[name] = { fn = fn, opts = opts }
      end

      typstwriter.create_commands()

      -- Verify main commands exist
      assert.is_not_nil(commands_created.TWriterNew)
      assert.is_not_nil(commands_created.TWriterCompile)
      assert.is_not_nil(commands_created.TWriterOpen)
      assert.is_not_nil(commands_created.TWriterBoth)
    end)
  end)

  describe("core utilities", function()
    it("should generate unique codes", function()
      local utils = typstwriter.utils
      local code1 = utils.generate_unique_code(8)
      local code2 = utils.generate_unique_code(8)

      assert.equals(8, #code1)
      assert.equals(8, #code2)
      assert.is_not_equal(code1, code2)
    end)

    it("should format filenames", function()
      local utils = typstwriter.utils
      local filename = utils.format_filename("test", "{name}-{code}.typ")

      assert.is_string(filename)
      assert.is_not_nil(filename:match("test%-[a-zA-Z0-9]+%.typ"))
    end)

    it("should check file existence", function()
      local utils = typstwriter.utils

      -- Mock vim.fn.filereadable for testing
      vim.fn.filereadable = function(path)
        return path == "/existing/file" and 1 or 0
      end

      assert.is_true(utils.file_exists("/existing/file"))
      assert.is_false(utils.file_exists("/nonexistent/file"))
    end)
  end)

  describe("compiler basic functionality", function()
    it("should compile typst files", function()
      local compiler = typstwriter.compiler
      local system_commands = {}

      -- Mock successful compilation
      vim.fn.system = function(cmd)
        table.insert(system_commands, cmd)
        return "Success"
      end
      vim.v.shell_error = 0

      -- Mock file checks
      vim.fn.expand = function(pattern)
        if pattern == "%:e" then
          return "typ"
        end
        if pattern == "%:p" then
          return "/test/file.typ"
        end
        return pattern
      end
      vim.fn.filereadable = function()
        return 1
      end
      vim.fn.executable = function()
        return 1
      end

      local success = compiler.compile_current("/test/file.typ")

      assert.is_true(success)
      assert.equals(1, #system_commands)
      assert.is_not_nil(system_commands[1]:match("typst compile"))
    end)
  end)

  describe("plugin info", function()
    it("should provide plugin information", function()
      -- Mock the PDF opener check to avoid errors
      vim.fn.has = function(feature)
        if feature == "unix" then
          return 1
        end
        return 0
      end
      vim.fn.executable = function()
        return 1
      end

      local info = typstwriter.info()

      assert.equals("typstwriter.nvim", info.name)
      assert.equals("1.0.0", info.version)
      assert.equals("gl1tchc0d3r", info.author)
      assert.is_table(info.config)
      assert.is_table(info.requirements)
    end)
  end)
end)
