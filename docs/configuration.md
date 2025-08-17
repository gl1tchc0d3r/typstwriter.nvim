---
layout: default
title: Configuration
---

# Configuration

typstwriter.nvim uses a deep merge configuration system with sensible defaults. All configuration is optional.

## Default Configuration

```lua
require("typstwriter").setup({
  notes_dir = "~/Documents/notes",
  template_dir = nil,  -- defaults to notes_dir/templates/v2
  default_template_type = "note",
  auto_date = true,
  use_random_suffix = true,
  auto_compile = false,
  open_after_compile = true,
  require_metadata = true,
  required_fields = { "type", "title" },
  keymaps = {
    new_document = "<leader>Tn",
    compile = "<leader>Tp", 
    open_pdf = "<leader>To",
    compile_and_open = "<leader>Tb"
  }
})
```

## Configuration Options

### Directory Settings

#### `notes_dir` (string)
- **Default**: `"~/Documents/notes"`
- **Description**: Root directory for your notes and documents
- **Example**: `notes_dir = "~/my-docs"`

#### `template_dir` (string | nil)
- **Default**: `nil` (uses `notes_dir/templates/v2`)
- **Description**: Directory containing Typst templates
- **Example**: `template_dir = "~/typst-templates"`

### Document Creation

#### `default_template_type` (string)
- **Default**: `"note"`
- **Description**: Default template type when creating new documents
- **Example**: `default_template_type = "article"`

#### `auto_date` (boolean)
- **Default**: `true`
- **Description**: Automatically set date in document metadata
- **Example**: `auto_date = false`

#### `use_random_suffix` (boolean)
- **Default**: `true`
- **Description**: Add random suffix to filenames to prevent collisions
- **Example**: `use_random_suffix = false`

### Compilation Settings

#### `auto_compile` (boolean)
- **Default**: `false`
- **Description**: Automatically compile documents on save
- **Example**: `auto_compile = true`

#### `open_after_compile` (boolean)
- **Default**: `true`
- **Description**: Open PDF after successful compilation
- **Example**: `open_after_compile = false`

### Template Validation

#### `require_metadata` (boolean)
- **Default**: `true`
- **Description**: Require templates to have metadata blocks
- **Example**: `require_metadata = false`

#### `required_fields` (table)
- **Default**: `{ "type", "title" }`
- **Description**: Required metadata fields for templates
- **Example**: `required_fields = { "type", "title", "author" }`

### Keymaps

#### `keymaps` (table | false)
- **Default**: See above
- **Description**: Keymap bindings (set to `false` to disable)
- **Scope**: Typst files only (except `new_document` which is global)

**Available keymaps**:
- `new_document`: Create new document (global)
- `compile`: Compile current document
- `open_pdf`: Open PDF of current document
- `compile_and_open`: Compile and open PDF

**Disable all keymaps**:
```lua
require("typstwriter").setup({
  keymaps = false
})
```

**Custom keymaps**:
```lua
require("typstwriter").setup({
  keymaps = {
    new_document = "<leader>nn",
    compile = "<leader>cc",
    open_pdf = "<leader>oo",
    compile_and_open = "<leader>cb"
  }
})
```

## Example Configurations

### Minimal Configuration
```lua
require("typstwriter").setup({
  notes_dir = "~/notes"
})
```

### Academic Writing Setup
```lua
require("typstwriter").setup({
  notes_dir = "~/research",
  template_dir = "~/research/templates",
  default_template_type = "paper",
  auto_date = true,
  use_random_suffix = false,
  required_fields = { "type", "title", "author", "date" },
  keymaps = {
    new_document = "<leader>rn",
    compile = "<leader>rc",
    open_pdf = "<leader>ro",
    compile_and_open = "<leader>rb"
  }
})
```

### Distraction-Free Setup
```lua
require("typstwriter").setup({
  auto_compile = true,
  open_after_compile = false,
  keymaps = {
    new_document = "<leader>n",
    compile = false,  -- disable since auto_compile is on
    open_pdf = "<leader>o",
    compile_and_open = false
  }
})
```

## Advanced Configuration

### Path Expansion
All path configurations support:
- `~` for home directory
- Environment variables: `$HOME/notes`
- Relative paths: `./notes`

### Directory Creation
typstwriter.nvim automatically creates:
- Notes directory if it doesn't exist
- Template directory if it doesn't exist
- Subdirectories as needed

### Template Discovery
Templates are discovered by:
1. Scanning `template_dir` for `.typ` files
2. Using `typst query` to extract metadata
3. Validating required fields
4. Building template registry

## Configuration Validation

The plugin validates your configuration and will show warnings for:
- Invalid directory paths
- Missing required fields in templates
- Conflicting settings

Check configuration status with:
```vim
:TypstWriterStatus
```

## Next Steps

- Learn about available [Commands](commands.html)
- Explore the [Template System](templates.html)
- Check out [Development Documentation](development/) for advanced usage
