---
layout: default
title: Commands
---

# Commands

typstwriter.nvim uses a unified CLI-style command structure that groups related functionality under subcommands, similar to tools like `git`, `docker`, or `kubectl`.

## Main Command

All functionality is accessed through the main `:TypstWriter` command:

```vim
:TypstWriter <subcommand> [options] [arguments]
```

## Command Structure

### Document Operations

These are the most frequently used commands for working with documents:

| Command | Description |
|---------|-------------|
| `:TypstWriter new` | Create new document from template |
| `:TypstWriter compile` | Compile current document to PDF |
| `:TypstWriter open` | Open PDF of current document |
| `:TypstWriter both` | Compile and open PDF in one step |
| `:TypstWriter status` | Show document and system status |

### Template Management

Commands for working with templates:

| Command | Description |
|---------|-------------|
| `:TypstWriter templates list` | List all available templates |

### Package Management

Commands for managing the typstwriter package system:

| Command | Description |
|---------|-------------|
| `:TypstWriter package status` | Show package installation status |
| `:TypstWriter package install` | Install typstwriter package to XDG location |
| `:TypstWriter package templates` | Setup templates with XDG package imports |

### System Operations

Commands for system setup and maintenance:

| Command | Description |
|---------|-------------|
| `:TypstWriter setup` | Complete system setup (package + templates) |
| `:TypstWriter help` | Show help information |

## Detailed Command Reference

### Document Commands

#### `:TypstWriter new`
Creates a new document from a template.

**Interactive Process:**
1. Select from available templates via fuzzy finder
2. Enter document title
3. Document is created with updated metadata
4. File opens automatically in Neovim
5. Auto-compiles if `auto_compile` is enabled

**Example workflow:**
```vim
:TypstWriter new
" → Select "NOTE: Quick Note Template"
" → Enter "Meeting with John"
" → Creates meeting-with-john-a1b2c3d4.typ
```

#### `:TypstWriter compile`
Compiles the current Typst document to PDF.

**Features:**
- Validates metadata if `require_metadata` is enabled
- Uses home directory as compilation root
- Includes bundled fonts from package system
- Provides clear success/error feedback

**Requirements:**
- Current buffer must be a `.typ` file
- Typst binary must be installed
- Document must have valid metadata (if required)

#### `:TypstWriter open`
Opens the PDF corresponding to the current Typst document.

**Cross-platform support:**
- **Linux**: Uses `xdg-open`
- **macOS**: Uses `open`
- **Windows**: Uses `start`

**Behavior:**
- Checks if PDF exists before attempting to open
- Opens PDF asynchronously (non-blocking)
- Shows user-friendly error messages if PDF opener is unavailable

#### `:TypstWriter both`
Convenience command that compiles and opens the PDF in sequence.

**Process:**
1. Compile current document
2. Wait 800ms for compilation to complete
3. Open the resulting PDF

#### `:TypstWriter status`
Shows comprehensive status information for the current document and system.

**Information displayed:**
- **File paths**: Typst file and corresponding PDF location
- **System requirements**: Typst binary and PDF opener availability
- **File status**: Existence and currency of files
- **Metadata**: Parsing status, validation results, and content
- **Recommendations**: Actionable next steps

**Example output:**
```
TypstWriter Status
==================
File: /home/user/notes/meeting-notes-a1b2c3d4.typ
PDF:  /home/user/notes/meeting-notes-a1b2c3d4.pdf

System:
  Typst binary:     ✓
  PDF opener:       ✓

Files:
  Typst exists:     ✓
  PDF exists:       ✓
  PDF up to date:   ✓

Metadata:
  Has metadata:     ✓
  Type:             meeting
  Title:            Meeting with John
  Status:           draft
  Tags:             work, meeting
  Valid metadata:   ✓

✅ Everything looks good!
```

### Template Commands

#### `:TypstWriter templates list`
Lists all available templates with their metadata status.

**Output format:**
```
Available templates:
======================
  ✓ article      Article Template for longer-form writing
  ✓ meeting      Meeting Notes Template with participant tracking
  ✓ note         Quick Note Template for daily thoughts
  ! old-template Legacy template without metadata

✓ = Has metadata, ! = No metadata
Template directory: /home/user/Documents/notes/templates/v2
```

### Package Commands

#### `:TypstWriter package status`
Shows detailed information about the package installation system.

**Information displayed:**
- Platform details (OS, XDG directories)
- Package installation status
- Template count
- Package size and font information

**Example output:**
```
typstwriter Package Status (XDG)
================================
Platform: Linux
XDG Data Dir: /home/user/.local/share/nvim
Package Dir:  /home/user/.local/share/nvim/typstwriter/packages/typstwriter
Template Dir: /home/user/Documents/notes/templates/v2

Package installed:  ✓
Templates count:    5

✅ XDG package system ready!
📁 Package includes bundled fonts (32MB)
```

#### `:TypstWriter package install`
Installs the typstwriter package to the XDG-compliant location.

**Process:**
1. Creates XDG directories if needed
2. Copies package files from plugin directory
3. Verifies successful installation
4. Reports installation path

**Package contents:**
- Typst module files
- Bundled fonts (~32MB)
- Style definitions
- Import configurations

#### `:TypstWriter package templates`
Sets up templates in your template directory with correct XDG package imports.

**Process:**
1. Ensures template directory exists
2. Verifies package is installed
3. Copies templates from plugin
4. Updates import paths to use XDG package location
5. Reports number of templates installed

### System Commands

#### `:TypstWriter setup`
Performs complete system setup in one command.

**Process:**
1. Installs package to XDG location
2. Sets up templates with correct imports
3. Verifies everything is working
4. Provides status feedback throughout

**This is equivalent to:**
```vim
:TypstWriter package install
:TypstWriter package templates
```

#### `:TypstWriter help`
Shows help information for the command system.

**Features:**
- Overview of all available commands
- Usage patterns and examples
- References to detailed documentation

## Tab Completion

The command system supports intelligent tab completion at every level:

```vim
:TypstWriter <Tab>
" → Shows: both, compile, help, new, open, package, setup, status, templates

:TypstWriter package <Tab>
" → Shows: install, status, templates

:TypstWriter templates <Tab>
" → Shows: list
```

## Migration from Old Commands

The new CLI structure replaces the previous individual commands:

| Old Command | New Command |
|-------------|-------------|
| `:TypstWriterNew` | `:TypstWriter new` |
| `:TypstWriterCompile` | `:TypstWriter compile` |
| `:TypstWriterOpen` | `:TypstWriter open` |
| `:TypstWriterBoth` | `:TypstWriter both` |
| `:TypstWriterStatus` | `:TypstWriter status` |
| `:TypstWriterTemplates` | `:TypstWriter templates list` |
| `:TypstWriterSetup` | `:TypstWriter setup` |
| `:TypstWriterPackageStatus` | `:TypstWriter package status` |
| `:TypstWriterInstallPackage` | `:TypstWriter package install` |
| `:TypstWriterSetupTemplates` | `:TypstWriter package templates` |

## Error Handling

The command system provides helpful error messages:

- **Unknown command**: Lists available subcommands
- **Incomplete command**: Shows possible completions
- **Missing requirements**: Guides toward resolution
- **File errors**: Clear explanations with next steps

## Tips

1. **Use tab completion** - It's the fastest way to discover and navigate commands
2. **Start with `:TypstWriter help`** - Get an overview of all functionality
3. **Check status first** - `:TypstWriter status` shows what's working and what needs attention
4. **One-time setup** - Run `:TypstWriter setup` once after installation
5. **Keybindings still work** - Your configured keymaps continue to function as before
