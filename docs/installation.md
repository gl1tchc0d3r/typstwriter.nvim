---
layout: default
title: Installation
---

# Installation

## Prerequisites

### Required
- **Neovim** >= 0.7.0
- **Typst binary** from [typst.app](https://typst.app)

### Recommended
- **PDF viewer** (system default)
- **Nerd Font** for icons

## Install Typst

First, install the Typst binary:

### Package Managers
```bash
# macOS (Homebrew)
brew install typst

# Arch Linux
pacman -S typst

# Windows (Winget)
winget install --id Typst.Typst
```

### From Source
```bash
cargo install --locked typst-cli
```

### Verify Installation
```bash
typst --version
```

## Install typstwriter.nvim

### Using lazy.nvim (Recommended)

```lua
{
  "gl1tchc0d3r/typstwriter.nvim",
  ft = { "typst" },
  config = function()
    require("typstwriter").setup({
      -- Configuration options (see Configuration page)
    })
  end,
}
```

### Using packer.nvim

```lua
use {
  "gl1tchc0d3r/typstwriter.nvim",
  config = function()
    require("typstwriter").setup()
  end,
}
```

### Using vim-plug

```vim
Plug 'gl1tchc0d3r/typstwriter.nvim'

lua << EOF
require("typstwriter").setup()
EOF
```

## Initial Setup

After installation, run the one-time setup and status check:

```vim
:TypstWriter setup     " Complete system setup
:TypstWriter status    " Check system status
```

This will check:
- Typst binary installation
- PDF viewer availability
- Directory structure
- Template validation

## Quick Test

1. Create a test document:
   ```vim
   :TypstWriter new
   ```

2. Select a template and provide a title

3. Compile the document:
   ```vim
   :TypstWriter both
   ```

If everything works, you should see a PDF open with your document!

## Troubleshooting

### Typst Binary Not Found
- Ensure `typst` is in your PATH
- Check installation with `typst --version`
- On some systems, you may need to restart your terminal

### PDF Won't Open
- Install a PDF viewer (e.g., `evince`, `okular`, `zathura` on Linux)
- Check your system's default PDF handler

### Templates Not Found
- The plugin will create default templates on first run
- Check `:TypstWriter status` for template directory location

## Next Steps

- [Configure](configuration.html) typstwriter.nvim to your preferences
- Learn about available [Commands](commands.html)
- Explore the [Template System](templates.html)
