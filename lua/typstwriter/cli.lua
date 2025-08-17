--- CLI command parser and router for typstwriter.nvim
--- Provides a unified command interface with subcommands
local utils = require("typstwriter.utils")
local M = {}

-- Command registry
local commands = {}

--- Register a command handler
--- @param path string Command path (e.g., "new", "templates.list")
--- @param handler function Command handler function
--- @param opts table|nil Command options (desc, complete, etc.)
function M.register_command(path, handler, opts)
  opts = opts or {}

  local parts = vim.split(path, ".", { plain = true })
  local current = commands

  -- Navigate to parent command
  for i = 1, #parts - 1 do
    local part = parts[i]
    if not current[part] then
      current[part] = {}
    end
    current = current[part]
  end

  -- Set the handler
  local final_key = parts[#parts]
  current[final_key] = {
    handler = handler,
    desc = opts.desc or "",
    complete = opts.complete,
  }
end

--- Get available subcommands at a given path
--- @param path string[] Command path parts
--- @return table Available subcommands
local function get_subcommands(path)
  local current = commands

  for _, part in ipairs(path) do
    if not current[part] or type(current[part]) ~= "table" then
      return {}
    end
    current = current[part]
  end

  local subcommands = {}
  for key, value in pairs(current) do
    if type(value) == "table" and (value.handler or next(value)) then
      table.insert(subcommands, key)
    end
  end

  return subcommands
end

--- Execute CLI command
--- @param opts table Command options from nvim_create_user_command
function M.execute(opts)
  local args = opts.fargs or {}

  if #args == 0 then
    M.show_help()
    return
  end

  -- Navigate to command handler
  local current = commands
  local path = {}

  for i, arg in ipairs(args) do
    table.insert(path, arg)

    if not current[arg] then
      utils.notify("Unknown command: " .. table.concat(path, " "), vim.log.levels.ERROR)
      return
    end

    current = current[arg]

    -- Check if this is a handler
    if type(current) == "table" and current.handler then
      local handler = current.handler
      -- Pass remaining args to handler
      local remaining_args = vim.list_slice(args, i + 1)
      handler(remaining_args, opts)
      return
    end
  end

  -- If we get here, the command path was incomplete
  local available = get_subcommands(path)
  if #available > 0 then
    utils.notify("Available subcommands: " .. table.concat(available, ", "), vim.log.levels.INFO)
  else
    utils.notify("Command not found: " .. table.concat(path, " "), vim.log.levels.ERROR)
  end
end

--- Tab completion for CLI commands
--- @param arg_lead string Current argument being completed
--- @param cmd_line string Full command line
--- @param cursor_pos number Cursor position
--- @return table Completion options
function M.complete(arg_lead, cmd_line, cursor_pos)
  -- Parse the command line to get current path
  local parts = vim.split(cmd_line, "%s+")
  table.remove(parts, 1) -- Remove ":TypstWriter"

  -- If we're completing the current argument, remove the incomplete part
  if arg_lead ~= "" then
    table.remove(parts)
  end

  local available = get_subcommands(parts)

  -- Filter by current input
  if arg_lead ~= "" then
    available = vim.tbl_filter(function(cmd)
      return cmd:find(arg_lead, 1, true) == 1
    end, available)
  end

  return available
end

--- Show help information
--- @param path string[]|nil Command path to show help for
function M.show_help(path)
  path = path or {}

  if #path == 0 then
    -- Show main help
    print("TypstWriter - Metadata-driven Typst writing system")
    print("Usage: :TypstWriter <subcommand> [options] [arguments]")
    print("")
    print("Available commands:")
    print("  new [template] [title]     Create new document from template")
    print("  compile                    Compile current document to PDF")
    print("  open                      Open PDF of current document")
    print("  both                      Compile and open PDF of current document")
    print("  templates list            List available templates")
    print("  templates copyexamples    Copy example templates to user directory")
    print("  package status            Show package installation status")
    print("  setup                     Complete system setup")
    print("  status                    Show system status")
    print("")
    print("Use ':TypstWriter help <command>' for detailed help on specific commands")
  else
    -- Show specific command help
    print("Help for: " .. table.concat(path, " "))
    -- TODO: Add detailed help for specific commands
  end
end

--- Initialize CLI commands
function M.setup()
  -- Document operations
  M.register_command("new", function(args, opts)
    require("typstwriter.templates").create_from_template()
  end, { desc = "Create new document from template" })

  M.register_command("compile", function(args, opts)
    require("typstwriter.document").compile_current()
  end, { desc = "Compile current document to PDF" })

  M.register_command("open", function(args, opts)
    require("typstwriter.document").open_pdf()
  end, { desc = "Open PDF of current document" })

  M.register_command("both", function(args, opts)
    require("typstwriter.document").compile_and_open()
  end, { desc = "Compile and open PDF" })

  -- Template operations
  M.register_command("templates.list", function(args, opts)
    require("typstwriter.templates").show_templates()
  end, { desc = "List available templates" })

  -- Package operations
  M.register_command("package.status", function(args, opts)
    require("typstwriter.package").show_status()
  end, { desc = "Show package installation status" })

  M.register_command("package.install", function(args, opts)
    require("typstwriter.package").install_package()
  end, { desc = "Install typstwriter package" })

  M.register_command("templates.copyexamples", function(args, opts)
    local success, message = require("typstwriter.templates").install_templates()
    if success then
      utils.notify(message, vim.log.levels.INFO)
    else
      utils.notify(message, vim.log.levels.ERROR)
    end
  end, { desc = "Copy example templates to user directory" })

  -- System operations
  M.register_command("setup", function(args, opts)
    require("typstwriter.package").setup()
  end, { desc = "Complete system setup" })

  M.register_command("status", function(args, opts)
    require("typstwriter.document").show_status()
  end, { desc = "Show system status and metadata info" })

  -- Help command
  M.register_command("help", function(args, opts)
    M.show_help(args)
  end, { desc = "Show help information" })
end

return M
