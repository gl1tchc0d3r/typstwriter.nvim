# XDG Package System Guide

## Overview

Typstwriter.nvim uses an **XDG-compliant package system** that stores the typstwriter package and bundled fonts in system data directories, separate from your templates. This ensures consistent typography across platforms and follows OS conventions for application data storage.

## Architecture

### XDG-Compliant Storage
- **Linux**: `~/.local/share/nvim/typstwriter/`
- **macOS**: `~/Library/Application Support/nvim/typstwriter/`
- **Windows**: `%LOCALAPPDATA%/nvim/typstwriter/`

### Separation of Concerns
- **Package & Fonts**: Stored in XDG data directories (managed by plugin)
- **Templates**: Stored in your configured `template_dir` (user-managed)
- **Documents**: Created in your `notes_dir` with absolute import paths

## First-Time Setup

After installing typstwriter.nvim with your plugin manager, run:

```vim
:TypstWriterSetup
```

This command will:
1. Install the typstwriter package to XDG-compliant directories
2. Install professional fonts (~32MB) for consistent typography
3. Install template files with correct absolute import paths
4. Verify everything is working correctly

## Available Commands

### `:TypstWriterSetup`
Complete setup - installs package, fonts, and templates (recommended for first-time users)

### `:TypstWriterPackageStatus` 
Check XDG installation status and see what's installed

### `:TypstWriterInstallPackage`
Install/update just the package and fonts (without templates)

### `:TypstWriterSetupTemplates`
Install/update just the templates (without package/fonts)

## What Gets Installed

### XDG Package Installation

**Linux Example** (`~/.local/share/nvim/typstwriter/`):
```
~/.local/share/nvim/typstwriter/
├── package/
│   ├── typst.toml           # Package manifest
│   ├── lib.typ              # Main library entry point
│   ├── core/                # Core styling functions
│   │   ├── base.typ         # Base typography and layout
│   │   ├── document.typ     # Document structure
│   │   └── metadata.typ     # Metadata handling
│   ├── themes/              # Theme definitions
│   └── components/          # Reusable components
└── fonts/                   # Bundled professional fonts (~32MB)
    ├── IosevkaNerdFont-Regular.ttf
    ├── HackNerdFont-Regular.ttf
    └── NotoColorEmoji.ttf
```

### Template Directory

**Your configured `template_dir`**:
```
templates/
├── meeting.typ              # Meeting notes template
├── note.typ                 # General note template
├── project.typ              # Project documentation template
├── article.typ              # Article template
└── report.typ               # Report template
```

### Template Files
- Templates are installed to your configured `template_dir`
- Import paths use absolute paths to XDG package installation
- Existing templates are never overwritten (safe to customize)
- New documents created from templates get automatic path adjustments

## Import Paths in Templates

Templates use absolute imports to the XDG installation:

```typst
#import "/home/user/.local/share/nvim/typstwriter/package/lib.typ": *

#metadata((
  title: "Document Title",
  date: "2025-08-16",
  status: "draft",
))

#show: note_template

= Document Title

Content using bundled fonts and consistent styling.
```

**Path Resolution:**
- Paths are automatically determined based on your operating system
- Templates installed by the plugin have correct paths
- Documents created from templates inherit the correct import paths

## Font System

### Bundled Fonts (~32MB)
- **Iosevka Nerd Font** - Primary proportional and monospace fonts
- **Hack Nerd Font Mono** - Alternative monospace with excellent readability
- **Noto Color Emoji** - Full color emoji support

### Font Path Integration
- Fonts are automatically provided to Typst via `--font-path`
- No system font installation required
- Consistent typography across Linux, macOS, and Windows
- Documents render identically regardless of system fonts

## Configuration

### Basic Configuration

```lua
require("typstwriter").setup({
  notes_dir = "~/Documents/notes",
  template_dir = "~/Documents/notes/templates", -- Templates here, package in XDG
  -- ... other config
})
```

### XDG Directory Override (Advanced)

By default, the plugin uses standard XDG directories. You typically don't need to change this, but if required:

```lua
-- Note: This is usually not necessary - XDG directories are auto-detected
require("typstwriter").setup({
  -- Standard user configuration
  notes_dir = "~/Documents/notes",
  template_dir = "~/Documents/notes/templates",
  -- XDG directories are handled automatically
})
```

## Troubleshooting

### "Package not installed" warning
- Run `:TypstWriterSetup` to install the XDG package system
- Check `:TypstWriterPackageStatus` for detailed installation status

### Import errors in templates
- Ensure package is installed with `:TypstWriterPackageStatus`
- Templates should use absolute imports to XDG directories
- Import paths are automatically set during template installation/creation
- Re-run `:TypstWriterSetup` if package needs updating

### Font issues
- Check `:TypstWriterPackageStatus` - fonts should be installed to XDG directories
- Verify the fonts directory exists in XDG installation
- Re-run `:TypstWriterSetup` to reinstall fonts
- Font warnings during compilation are often harmless fallback messages

### Templates not found
- Run `:TypstWriterSetupTemplates` to install template files
- Check that `template_dir` is configured correctly
- Run `:TypstWriterTemplates` to list available templates

### Permission issues
- Ensure you have write permissions to XDG directories
- On Linux: `~/.local/share/nvim/` should be user-writable
- On macOS: `~/Library/Application Support/nvim/` should be accessible
- On Windows: `%LOCALAPPDATA%/nvim/` should be writable

## Updating

When you update typstwriter.nvim:
- Run `:TypstWriterSetup` again to update packages, fonts, and templates
- Your customized templates won't be overwritten
- New templates will be added if available
- Package and font updates are automatically handled

## Benefits of XDG System

### For Users
- **No font installation required** - everything works out of the box
- **Consistent typography** - documents look identical across platforms
- **Clean separation** - templates stay in your workspace, system files in appropriate directories
- **OS conventions** - follows platform standards for data storage

### For Developers
- **Standards compliance** - follows XDG Base Directory Specification
- **Cross-platform compatibility** - works on Linux, macOS, and Windows
- **Maintainable** - clear separation between user data and application data
- **Scalable** - foundation for future package management features
