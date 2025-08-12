local helpers = require("helpers")

describe("typstwriter templates", function()
  local templates

  before_each(function()
    helpers.mock_vim()

    -- Mock the config module
    package.loaded["typstwriter.config"] = {
      get = function(key)
        if key == "template_dir" then
          return "/test/templates"
        end
        if key == "notes_dir" then
          return "/test/notes"
        end
        if key == "filename_format" then
          return "{name}-{code}"
        end
        if key == "code_length" then
          return 6
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

    templates = require("typstwriter.templates")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("get_available_templates", function()
    it("should return available templates", function()
      local config = require("typstwriter.config")
      config.get = function(key)
        if key == "template_dir" then
          return "/test/templates"
        end
        return nil
      end

      -- Mock directory exists
      vim.fn.isdirectory = function()
        return 1
      end
      -- Mock glob to return template files
      vim.fn.glob = function(pattern)
        return { "/test/templates/basic.typ", "/test/templates/academic.typ" }
      end
      -- Mock filename functions
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":t" then
          return path:match("/([^/]+)$")
        elseif modifier == ":t:r" then
          return path:match("/([^/]+)%.typ$")
        end
        return path
      end

      local available = templates.get_available_templates()
      assert.is_table(available)
      assert.is_not_nil(available.basic)
      assert.is_not_nil(available.academic)
      assert.equals("Basic template", available.basic.description)
    end)
  end)

  describe("list_templates", function()
    it("should return formatted template list", function()
      local config = require("typstwriter.config")
      config.get = function(key)
        if key == "template_dir" then
          return "/test/templates"
        end
        return nil
      end

      -- Mock directory exists
      vim.fn.isdirectory = function()
        return 1
      end
      -- Mock glob to return template files
      vim.fn.glob = function(pattern)
        return { "/test/templates/basic.typ", "/test/templates/academic.typ" }
      end
      -- Mock filename functions
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":t" then
          return path:match("/([^/]+)$")
        elseif modifier == ":t:r" then
          return path:match("/([^/]+)%.typ$")
        end
        return path
      end

      local template_list = templates.list_templates()

      assert.is_table(template_list)
      assert.equals(2, #template_list)
      -- Should be a sorted array of template info objects
      assert.is_string(template_list[1].name)
      assert.is_string(template_list[1].description)
    end)
  end)

  describe("create_document", function()
    it("should create document from template", function()
      local config = require("typstwriter.config")
      config.get = function(key)
        if key == "template_dir" then
          return "/test/templates"
        elseif key == "notes_dir" then
          return "/test/notes"
        elseif key == "filename_format" then
          return "{name}-{code}"
        elseif key == "code_length" then
          return 6
        end
        return nil
      end

      -- Mock directory exists and template files
      vim.fn.isdirectory = function()
        return 1
      end
      vim.fn.glob = function()
        return { "/test/templates/basic.typ" }
      end
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":t" then
          return "basic.typ"
        end
        if modifier == ":t:r" then
          return "basic"
        end
        return path
      end
      vim.fn.filereadable = function(filepath)
        -- Template file exists, but new file doesn't exist yet
        if filepath:match("templates.*basic%.typ$") then
          return 1 -- Template exists
        end
        return 0 -- New file doesn't exist
      end
      vim.fn.confirm = function(msg, choices, default)
        return 1 -- Always confirm "Yes" for overwrite
      end
      vim.fn.system = function()
        return ""
      end
      vim.v.shell_error = 0
      vim.cmd = function() end

      -- Add debug mocking to track what's happening
      local notify_messages = {}
      vim.notify = function(msg, level)
        table.insert(notify_messages, { msg = msg, level = level })
      end

      local success = templates.create_document("basic", "test-doc")

      -- Debug: print all notify messages if test fails
      if not success then
        for _, msg in ipairs(notify_messages) do
          print("Notify:", msg.msg, "Level:", msg.level)
        end
      end

      assert.is_true(success)
    end)
  end)

  describe("create_from_template", function()
    it("should check for typst binary", function()
      local error_messages = {}
      vim.notify = function(msg, level)
        if level >= vim.log.levels.ERROR then
          table.insert(error_messages, msg)
        end
      end
      vim.fn.executable = function()
        return 0
      end -- Typst not found
      templates.create_from_template()
      assert.equals(1, #error_messages)
      assert.is_not_nil(error_messages[1]:match("Typst binary not found"))
    end)
  end)

  describe("show_templates", function()
    it("should display template information", function()
      local config = require("typstwriter.config")
      config.get = function(key)
        if key == "template_dir" then
          return "/test/templates"
        end
        return nil
      end

      -- Mock directory exists and has templates
      vim.fn.isdirectory = function()
        return 1
      end
      vim.fn.glob = function()
        return { "/test/templates/basic.typ" }
      end
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":t" then
          return "basic.typ"
        end
        if modifier == ":t:r" then
          return "basic"
        end
        return path
      end
      local printed = {}
      _G.print = function(msg)
        table.insert(printed, msg or "")
      end
      templates.show_templates()
      -- Should print headers and template info
      assert.is_true(#printed > 0)
      local output = table.concat(printed, "\n")
      assert.is_not_nil(output:match("Available templates"))
    end)
  end)
end)
