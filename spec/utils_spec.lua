local helpers = require("helpers")

describe("typstwriter utils", function()
  local utils, config

  before_each(function()
    helpers.mock_vim()

    -- Mock the config module
    package.loaded["typstwriter.config"] = {
      get = function(key)
        if key == "code_length" then
          return 6
        end
        if key == "filename_format" then
          return "{name}-{code}"
        end
        if key == "use_modern_ui" then
          return true
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
      setup = function() end,
    }

    utils = require("typstwriter.utils")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("generate_unique_code", function()
    it("should generate code of default length", function()
      local code = utils.generate_unique_code()
      assert.equals(6, #code) -- default length
    end)

    it("should generate code of specified length", function()
      local code = utils.generate_unique_code(10)
      assert.equals(10, #code)
    end)

    it("should generate different codes on subsequent calls", function()
      local code1 = utils.generate_unique_code()
      local code2 = utils.generate_unique_code()
      assert.is_not_equal(code1, code2)
    end)

    it("should only contain alphanumeric characters", function()
      local code = utils.generate_unique_code(100) -- Large sample
      assert.is_true(code:match("^[a-zA-Z0-9]+$") ~= nil)
    end)
  end)

  describe("format_filename", function()
    it("should replace {name} placeholder", function()
      local filename = utils.format_filename("test-doc")
      assert.is_string(filename)
      assert.is_not_nil(filename:match("test%-doc"))
    end)

    it("should replace {date} placeholder", function()
      local filename = utils.format_filename("test", "{name}-{date}.typ")
      assert.is_string(filename)
      assert.is_not_nil(filename:match("test%-2025")) -- assuming current year
    end)

    it("should replace {code} placeholder", function()
      local filename = utils.format_filename("test", "{name}-{code}.typ")
      assert.is_string(filename)
      assert.is_not_nil(filename:match("test%-[a-zA-Z0-9]+"))
    end)

    it("should ensure .typ extension", function()
      local filename1 = utils.format_filename("test", "{name}")
      assert.is_true(filename1:match("%.typ$") ~= nil)

      local filename2 = utils.format_filename("test", "{name}.typ")
      assert.equals(1, select(2, filename2:gsub("%.typ", ""))) -- Should only appear once
    end)
  end)

  describe("file operations", function()
    it("file_exists should return true for readable files", function()
      assert.is_true(utils.file_exists("/some/path"))
    end)

    it("dir_exists should return true for directories", function()
      assert.is_true(utils.dir_exists("/some/dir"))
    end)

    it("get_pdf_path should convert .typ to .pdf", function()
      -- Mock vim.fn.fnamemodify to simulate the actual behavior
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":r" then
          return path:gsub("%.typ$", "")
        end
        return path
      end

      local pdf_path = utils.get_pdf_path("/path/to/document.typ")
      assert.equals("/path/to/document.pdf", pdf_path)
    end)
  end)

  describe("system utilities", function()
    it("has_typst should check for typst executable", function()
      assert.is_true(utils.has_typst()) -- Mocked to return true
    end)

    it("get_pdf_opener should return appropriate opener", function()
      local opener = utils.get_pdf_opener()
      assert.is_not_nil(opener)
    end)

    it("system_exec should execute commands", function()
      local success = utils.system_exec("echo test", "Success", "Error")
      assert.is_true(success)
    end)
  end)

  describe("UI utilities", function()
    it("use_modern_ui should return true when vim.ui is available", function()
      local result = utils.use_modern_ui()
      assert.is_truthy(result) -- Should return a truthy value when all conditions are met
    end)

    it("select should call callback with selection", function()
      local selected = nil
      utils.select({ "option1", "option2" }, {}, function(choice)
        selected = choice
      end)
      assert.equals("option1", selected)
    end)

    it("input should call callback with input", function()
      local input_result = nil
      utils.input({ prompt = "Test:" }, function(result)
        input_result = result
      end)
      assert.equals("test", input_result)
    end)
  end)

  describe("string utilities", function()
    it("capitalize should capitalize first letter", function()
      assert.equals("Hello", utils.capitalize("hello"))
      assert.equals("HELLO", utils.capitalize("hELLO"))
      assert.equals("", utils.capitalize(""))
      assert.equals("A", utils.capitalize("a"))
    end)
  end)

  describe("notify", function()
    it("should call vim.notify when notifications enabled", function()
      local notify_called = false
      local notify_message = nil
      vim.notify = function(msg, level)
        notify_called = true
        notify_message = msg
      end

      utils.notify("test message")

      assert.is_true(notify_called)
      assert.equals("test message", notify_message)
    end)

    it("should not call vim.notify when notifications disabled", function()
      -- Override config to disable notifications
      package.loaded["typstwriter.config"].should_notify = function()
        return false
      end

      local notify_called = false
      vim.notify = function(msg, level)
        notify_called = true
      end

      utils.notify("test message")

      assert.is_false(notify_called)
    end)
  end)
end)
