local helpers = require("helpers")

describe("typstwriter config", function()
  local config

  before_each(function()
    helpers.mock_vim()
    config = require("typstwriter.config")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("default configuration", function()
    it("should have sensible defaults", function()
      assert.is_not_nil(config.defaults)
      assert.equals("/tmp/test/Documents/notes", config.defaults.notes_dir)
      assert.equals("{name}.{code}.typ", config.defaults.filename_format)
      assert.equals(6, config.defaults.code_length)
      assert.is_false(config.defaults.auto_compile)
      assert.is_true(config.defaults.open_after_compile)
    end)
  end)

  describe("setup", function()
    it("should merge user config with defaults", function()
      local user_config = {
        notes_dir = "~/custom-notes",
        auto_compile = true,
        code_length = 8,
      }

      config.setup(user_config)

      assert.equals("/tmp/test/custom-notes", config.current.notes_dir)
      assert.is_true(config.current.auto_compile)
      assert.equals(8, config.current.code_length)
      -- Should keep other defaults
      assert.equals("{name}.{code}.typ", config.current.filename_format)
    end)

    it("should set template_dir default if not provided", function()
      config.setup({ notes_dir = "~/test" })

      assert.equals("/tmp/test/test/typst-templates", config.current.template_dir)
    end)

    it("should expand paths", function()
      config.setup({
        notes_dir = "~/notes",
        template_dir = "~/templates",
      })

      assert.equals("/tmp/test/notes", config.current.notes_dir)
      assert.equals("/tmp/test/templates", config.current.template_dir)
    end)
  end)

  describe("get", function()
    before_each(function()
      config.setup({
        auto_compile = true,
        notifications = {
          enabled = false,
          level = 4,
        },
      })
    end)

    it("should get simple config values", function()
      assert.is_true(config.get("auto_compile"))
      assert.equals(6, config.get("code_length")) -- default
    end)

    it("should get nested config values with dot notation", function()
      assert.is_false(config.get("notifications.enabled"))
      assert.equals(4, config.get("notifications.level"))
    end)

    it("should return nil for non-existent keys", function()
      assert.is_nil(config.get("non_existent"))
      assert.is_nil(config.get("notifications.non_existent"))
    end)
  end)

  describe("validation", function()
    it("should validate filename format contains {name}", function()
      local notify_called = false
      vim.notify = function(msg, level)
        if msg:match("filename_format.*{name}") then
          notify_called = true
        end
      end

      config.setup({ filename_format = "invalid-format" })

      assert.is_true(notify_called)
      assert.equals("{name}.{code}.typ", config.current.filename_format) -- Should reset to default
    end)

    it("should validate code_length range", function()
      local notify_called = false
      vim.notify = function(msg, level)
        if msg:match("code_length.*between 1 and 20") then
          notify_called = true
        end
      end

      config.setup({ code_length = 25 })

      assert.is_true(notify_called)
      assert.equals(6, config.current.code_length) -- Should reset to default
    end)
  end)

  describe("helper functions", function()
    it("should_notify should return notifications.enabled value", function()
      config.setup({ notifications = { enabled = true } })
      assert.is_true(config.should_notify())

      config.setup({ notifications = { enabled = false } })
      assert.is_false(config.should_notify())
    end)

    it("get_notification_level should return notifications.level value", function()
      config.setup({ notifications = { level = 4 } })
      assert.equals(4, config.get_notification_level())
    end)
  end)
end)
