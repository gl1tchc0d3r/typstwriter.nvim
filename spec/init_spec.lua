local helpers = require("helpers")

describe("typstwriter plugin", function()
  local typstwriter

  before_each(function()
    helpers.mock_vim()

    -- Mock the config module
    package.loaded["typstwriter.config"] = {
      get = function(key)
        return nil
      end,
      should_notify = function()
        return true
      end,
      get_notification_level = function()
        return vim.log.levels.INFO
      end,
      setup = function() end,
      current = { -- Mock current config table
        notes_dir = "~/typstwriter",
        template_dir = "~/typstwriter/templates",
        filename_format = "{name}-{code}",
      },
    }

    typstwriter = require("typstwriter")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("plugin structure", function()
    it("should expose main API", function()
      assert.is_not_nil(typstwriter.setup)
      assert.is_function(typstwriter.setup)
      assert.is_not_nil(typstwriter.create_commands)
      assert.is_not_nil(typstwriter.setup_keymaps)
    end)

    it("should expose submodules", function()
      assert.is_not_nil(typstwriter.config)
      assert.is_not_nil(typstwriter.utils)
      assert.is_not_nil(typstwriter.templates)
      assert.is_not_nil(typstwriter.compiler)
    end)
  end)

  describe("setup", function()
    it("should initialize plugin without errors", function()
      local commands_created = false
      local keymaps_setup = false
      local autocommands_setup = false
      local requirements_checked = false

      -- Mock the internal functions
      typstwriter.create_commands = function()
        commands_created = true
      end

      typstwriter.setup_keymaps = function()
        keymaps_setup = true
      end

      typstwriter.setup_autocommands = function()
        autocommands_setup = true
      end

      typstwriter.check_requirements = function()
        requirements_checked = true
      end

      -- Call setup
      typstwriter.setup({ notes_dir = "~/test-notes" })

      -- Verify all initialization steps were called
      assert.is_true(commands_created)
      assert.is_true(keymaps_setup)
      assert.is_true(autocommands_setup)
      assert.is_true(requirements_checked)
    end)
  end)

  describe("create_commands", function()
    it("should create all required user commands", function()
      local commands_created = {}

      vim.api.nvim_create_user_command = function(name, fn, opts)
        commands_created[name] = { fn = fn, opts = opts }
      end

      typstwriter.create_commands()

      -- Check all commands were created
      local expected_commands = {
        "TWriterNew",
        "TWriterCompile",
        "TWriterOpen",
        "TWriterBoth",
        "TWriterStatus",
        "TWriterTemplates",
      }

      for _, cmd in ipairs(expected_commands) do
        assert.is_not_nil(commands_created[cmd], "Command " .. cmd .. " was not created")
        assert.is_function(commands_created[cmd].fn)
        assert.is_not_nil(commands_created[cmd].opts.desc)
      end
    end)
  end)

  describe("info", function()
    it("should return plugin information", function()
      local info = typstwriter.info()

      assert.is_table(info)
      assert.equals("typstwriter.nvim", info.name)
      assert.equals("1.0.0", info.version)
      assert.is_string(info.description)
      assert.equals("gl1tchc0d3r", info.author)
      assert.is_table(info.config)
      assert.is_table(info.requirements)
    end)

    it("should report system requirements", function()
      local info = typstwriter.info()

      assert.equals(">=0.7.0", info.requirements.neovim)
      assert.is_boolean(info.requirements.typst)
      assert.is_boolean(info.requirements.pdf_opener)
    end)
  end)

  describe("requirements checking", function()
    it("should check for typst binary", function()
      local warnings = {}
      vim.notify = function(msg, level)
        if level >= vim.log.levels.WARN then
          table.insert(warnings, msg)
        end
      end

      -- Mock typst not available
      local utils = require("typstwriter.utils")
      utils.has_typst = function()
        return false
      end

      typstwriter.check_requirements()

      -- Should warn about missing typst
      local found_typst_warning = false
      for _, warning in ipairs(warnings) do
        if warning:match("Typst binary not found") then
          found_typst_warning = true
          break
        end
      end
      assert.is_true(found_typst_warning)
    end)
  end)
end)
