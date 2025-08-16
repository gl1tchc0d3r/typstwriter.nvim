# Package Setup Guide

## Overview
The typstwriter package system allows you to use structured templates with imports. Since Neovim plugins are installed in isolated directories (like with Lazy), templates can't directly import from the plugin's package directory. This system solves that by copying the package to your configured template directory.

## First-Time Setup

After installing typstwriter.nvim with your plugin manager, run:

```vim
:TypstWriterSetup
```

This command will:
1. Copy the typstwriter package to `~/Documents/notes/templates/packages/typstwriter/`
2. Install template files with correct import paths
3. Ensure everything is ready to use

## Available Commands

### `:TypstWriterSetup`
Complete setup - installs package and templates (recommended for first-time users)

### `:TypstWriterPackageStatus` 
Check installation status and see what's installed

### `:TypstWriterInstallPackage`
Install/update just the package (without templates)

### `:TypstWriterSetupTemplates`
Install/update just the templates (without package)

## What Gets Installed

### Package Structure
```
~/Documents/notes/templates/
├── packages/
│   └── typstwriter/
│       ├── typst.toml           # Package manifest
│       ├── core/                # Core styling functions
│       ├── templates/           # Template components  
│       ├── components/          # Reusable components
│       └── themes/              # Theme definitions
└── *.typ                        # Template files
```

### Template Files
- Templates are copied to your template directory
- Import paths are automatically adjusted to work from your directory
- Existing templates are never overwritten (safe to customize)

## Import Paths in Templates

Templates use relative imports like:
```typst
#import "./packages/typstwriter/core/style.typ": *
#import "./packages/typstwriter/themes/academic.typ": theme
```

These paths work correctly because the package is installed in your template directory.

## Configuration

You can customize the template directory in your Neovim config:

```lua
require("typstwriter").setup({
  template_dir = "~/my-templates",  -- Custom location
  -- ... other config
})
```

The package will be installed to `~/my-templates/packages/typstwriter/`.

## Troubleshooting

### "Package not installed" warning
Run `:TypstWriterSetup` to install the package system.

### Import errors in templates
- Check `:TypstWriterPackageStatus` to verify installation
- Ensure you're working from files in your template directory
- Import paths should use `"./packages/typstwriter/..."` format

### Templates not found
- Run `:TypstWriterSetupTemplates` to install template files
- Check that `template_dir` is configured correctly

## Updating

When you update typstwriter.nvim:
- Run `:TypstWriterSetup` again to update packages and templates
- Your customized templates won't be overwritten
- New templates will be added if available
