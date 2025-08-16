# typstwriter.nvim

> A complete Typst writing system for Neovim - from beautiful templates to intelligent personal knowledge management

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/gl1tchc0d3r/typstwriter.nvim/workflows/CI/badge.svg)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![Tests](https://img.shields.io/github/actions/workflow/status/gl1tchc0d3r/typstwriter.nvim/ci.yml?branch=main&label=tests)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![codecov](https://codecov.io/github/gl1tchc0d3r/typstwriter.nvim/graph/badge.svg?token=J3ZM26AFGP)](https://codecov.io/github/gl1tchc0d3r/typstwriter.nvim)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![Typst](https://img.shields.io/badge/Typst-compatible-blue.svg)](https://typst.app)

## Philosophy: Why This Plugin Exists

As one of the few "progressive conservatives" in computing, I've spent decades with vi, vim, and now Neovim in the terminal - this is how I've used computers since the early Unix days. While others chase shiny GUI applications wrapped in Electron, I remain committed to never leaving the terminal.

### The Challenge

Modern tools like **Obsidian**, **VS Code**, **Excel**, **PowerBI**, **DBeaver**, **AnyType** - they encapsulate powerful functionality behind frustrating mouse-driven interfaces. They assume you want to leave your keyboard-centric workflow for their "user-friendly" GUIs. I refuse.

### The Markup Evolution

**LaTeX** has been the gold standard for typesetting since the late 80s/early 90s - a rich, powerful tool in any academic's toolbox. With its vast ecosystem of plugins and adaptations, LaTeX's typesetting capabilities remain unmatched. But it's often frustrating and difficult to get right, with syntax that can become unreadable.

**Markdown** evolved with the HTML/CSS mindset - thinking in terms of web presentation with confusing CSS iterations to make it presentable. It gained readability but was fundamentally designed for web rendering, not professional typesetting.

**Typst** changed everything. It offers:
- The simplicity of Vimwiki-like basic syntax
- Typesetting power comparable to LaTeX on a bad day (but evolving rapidly)
- Readable markup that doesn't sacrifice functionality
- A modern approach designed for documents, not web pages

When I discovered Typst, it struck a chord. What if I could replace my entire Markdown vault with YAML frontmatter notes using this superior tool? The typesetting may not match LaTeX's full power yet, but it's more than sufficient for my needs and improving constantly. And so this plugin was born.

### What to Expect

✅ **A complete terminal-native writing system** - No GUI dependencies, ever  
✅ **Professional document output** - High-quality PDFs from readable markup  
✅ **Keyboard-driven workflow** - Everything accessible via keybindings and commands  
✅ **Progressive enhancement** - Starting with templates, evolving toward AI-assisted knowledge management  
✅ **Privacy-first approach** - Local processing, your data stays with you  
✅ **Beautiful typography** - Professional fonts and consistent styling out of the box  
✅ **Hackability above all** - Built to work exactly how you want it. As a progressive conservative, my preferences might change overnight - so everything stays configurable to change back the day after 😉

### What NOT to Expect

❌ **A GUI application** - This will never become an Electron app or require a browser  
❌ **Mouse-driven interface** - If you need to click things, this isn't for you  
❌ **Cloud dependencies** - No data harvesting, no mandatory accounts, no "sync services"  
❌ **LaTeX-level complexity** - We embrace Typst's simplicity over LaTeX's ultimate power  
❌ **Beginner-friendly onboarding** - This assumes you're comfortable with Neovim and the terminal  
❌ **Immediate perfection** - This is an evolving experiment in terminal-based knowledge management  
❌ **Overwhelming configurability (yet)** - First iteration focuses on core functionality; hackability will expand  
❌ **Support obligations** - Read the LICENSE: this is true open source → **Get everything, Expect nothing!**  
❌ **Guaranteed responses** - No expectations for pull requests, issues, code critique, or feedback  
❌ **Roadmap commitments** - Features may or may not happen, when they happen, if they happen  

### The Vision

With this plugin, I'm testing how far Typst can go as my primary markup tool, paired with my favorite terminal and Neovim workflow. The goal isn't to compete with mainstream tools - it's to prove that keyboard-driven, terminal-native productivity can be more powerful and pleasant than any GUI.

This is shared in the spirit of true open source: take it, fork it, improve it, or ignore it. I built this for myself, and I'm sharing it because others might find it useful. But I owe you nothing beyond what's already here.

If you share this philosophy, welcome to the experiment. If you're looking for another Electron app with pretty buttons or guaranteed support, you're in the wrong place.

## Current Features

### Package-Based Template System
- **XDG-compliant architecture** - Self-contained typstwriter package with modular components stored in system data directories
- **Bundled professional fonts** - Complete typography system (~32MB) with Iosevka NF, Hack Nerd Font, and Noto Color Emoji
- **One-command setup** - `:TypstWriterSetup` installs everything you need in XDG-compliant locations
- **Cross-platform font support** - Works consistently across Linux, macOS, and Windows without requiring system font installation
- **Import-based templates** - Templates use structured imports from the installed package system
- **Core styling library** - Shared typography, themes, and components across all templates
- **Template validation** - Ensures templates and package structure are properly installed

### Streamlined Workflow  
- **One-command document creation** from package-based templates
- **Integrated compilation** - compile to PDF and open instantly
- **Smart file naming** - generates clean filenames with metadata integration
- **Cross-platform** support (Linux, macOS, Windows)
- **Modern UI integration** with vim.ui.select/input when available

### Professional Output
- **Modular styling system** - Core styles, themes, and components in organized package structure
- **Consistent typography** - Professional font stacks and styling across all documents
- **Reusable components** - Import specific styling functions and themes as needed
- **Clean document structure** with proper heading hierarchy and spacing

## Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "gl1tchc0d3r/typstwriter.nvim",
  branch = "feature/local-package-library", -- Development branch with package system
  ft = "typst",
  cmd = {
    "TypstWriterNew",
    "TypstWriterCompile", 
    "TypstWriterOpen",
    "TypstWriterBoth",
    "TypstWriterStatus",
    "TypstWriterTemplates",
    "TypstWriterSetup",
    "TypstWriterPackageStatus",
    "TypstWriterInstallPackage",
    "TypstWriterSetupTemplates"
  },
  keys = {
    { "<leader>Tn", "<cmd>TypstWriterNew<cr>", desc = "New document" },
    { "<leader>Tc", "<cmd>TypstWriterCompile<cr>", desc = "Compile", ft = "typst" },
    { "<leader>To", "<cmd>TypstWriterOpen<cr>", desc = "Open PDF", ft = "typst" },
    { "<leader>Tb", "<cmd>TypstWriterBoth<cr>", desc = "Compile & open", ft = "typst" },
    { "<leader>Ts", "<cmd>TypstWriterSetup<cr>", desc = "Setup package system" },
  },
  config = function()
    require('typstwriter').setup({
      notes_dir = "~/Documents/notes",
      template_dir = "~/Documents/notes/templates", -- Templates stored here, package installed in XDG directories
    })
  end
}
```


## Configuration

### Default Configuration

```lua
require('typstwriter').setup({
  -- Directory settings
  notes_dir = "~/Documents/notes",
  template_dir = "~/Documents/notes/templates", -- Templates stored here, package installed in XDG directories
  
  -- Template preferences
  default_template_type = "note",
  auto_date = true, -- Automatically set date to today in metadata
  
  -- Filename generation
  use_random_suffix = true, -- Add random suffix for uniqueness
  random_suffix_length = 6, -- Length of random suffix
  
  -- Compilation settings
  auto_compile = false,
  open_after_compile = true,
  
  -- Key mappings (set to false to disable)
  keymaps = {
    new_document = "<leader>Tn",
    compile = "<leader>Tc",
    open_pdf = "<leader>To", 
    compile_and_open = "<leader>Tb",
  },
  
  -- Notifications
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO,
  },
})
```

### Custom Configuration Example

```lua
require('typstwriter').setup({
  notes_dir = "~/my-notes",
  template_dir = "~/my-notes/templates", -- Templates stored here, package installed in XDG directories
  auto_compile = true,
  use_random_suffix = false, -- Disable random suffixes
  auto_date = false, -- Don't auto-update dates
  keymaps = {
    new_document = "<leader>nn",
    compile = "<leader>cc",
    open_pdf = "<leader>oo",
    compile_and_open = false, -- Disable this keymap
  }
})
```

## Quick Start

### First-Time Setup

After installing the plugin, run the setup command:

```vim
:TypstWriterSetup
```

This will:
1. Install the typstwriter package to XDG-compliant directories (~/.local/share/nvim/typstwriter/)
2. Install ready-to-use templates with proper absolute imports
3. Bundle professional fonts for consistent typography across platforms
4. Verify everything is working correctly

### Package System Overview

The plugin uses an **XDG-compliant package architecture** where:
- Package and fonts are installed to system data directories (e.g., `~/.local/share/nvim/typstwriter/`)
- Templates use absolute import paths to the XDG package installation
- Bundled fonts ensure consistent typography without requiring system font installation
- Cross-platform compatibility with Linux, macOS, and Windows XDG specifications

## Usage

### Core Commands

| Command | Description |
|---------|-------------|
| `:TypstWriterNew` | Create new document from template |
| `:TypstWriterCompile` | Compile current document to PDF |
| `:TypstWriterOpen` | Open PDF of current document |
| `:TypstWriterBoth` | Compile and open PDF |
| `:TypstWriterStatus` | Show system status |
| `:TypstWriterTemplates` | List available templates |

### Package Management Commands

| Command | Description |
|---------|-------------|
| `:TypstWriterSetup` | Complete package and template setup |
| `:TypstWriterPackageStatus` | Check package installation status |
| `:TypstWriterInstallPackage` | Install/update package only |
| `:TypstWriterSetupTemplates` | Install/update templates only |

### Watch Mode & Auto-Compilation

The plugin supports automatic recompilation when files are saved:

```lua
require('typstwriter').setup({
  auto_compile = true,        -- Enable auto-compilation on save
  open_after_compile = true,  -- Auto-open PDF after compilation
})
```

With this configuration:
- Every time you save a Typst file (`:w`), it automatically recompiles
- The PDF viewer refreshes to show your changes instantly
- Perfect for real-time document editing and preview

**Note**: If you're using `TypstWatch` from another plugin (like `typst.vim`), that's separate from this templating plugin but works great alongside it!

### Default Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Tn` | Normal | Create new document |
| `<leader>Tc` | Normal (Typst files) | Compile to PDF |
| `<leader>To` | Normal (Typst files) | Open PDF |
| `<leader>Tb` | Normal (Typst files) | Compile and open |

### Basic Workflow

1. **Setup** (first time): Run `:TypstWriterSetup` to install the package system
2. **Create a new document**: Press `<leader>Tn` or run `:TypstWriterNew`
3. **Select template**: Choose from available templates
4. **Enter document title**: Provide a title for your document
5. **Edit**: The new file opens automatically with proper imports
6. **Compile**: Press `<leader>Tc` or run `:TypstWriterCompile`
7. **View**: Press `<leader>To` or run `:TypstWriterOpen` to view the PDF

## Package System Architecture

### Directory Structure

After running `:TypstWriterSetup`, the system creates:

**XDG Package Installation** (e.g., `~/.local/share/nvim/typstwriter/`):
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
│   │   ├── academic.typ     # Academic document theme
│   │   ├── modern.typ       # Modern business theme
│   │   └── minimal.typ      # Clean minimal theme
│   └── components/          # Reusable components
└── fonts/                   # Bundled professional fonts (~32MB)
    ├── IosevkaNerdFont-Regular.ttf
    ├── HackNerdFont-Regular.ttf
    └── NotoColorEmoji.ttf
```

**Template Directory** (your configured `template_dir`):
```
templates/
├── meeting.typ              # Meeting notes template
├── note.typ                 # General note template
├── project.typ              # Project documentation template
├── article.typ              # Article template
└── report.typ               # Report template
```

### Package-Based Templates

Templates use absolute imports from the XDG package installation:

```typst
#import "/home/user/.local/share/nvim/typstwriter/package/lib.typ": *

#metadata((
  title: "Document Title",
  date: "2025-08-16",
  status: "draft",
  tags: ("example", "template"),
))

#show: note_template

= Document Title

Content using consistent styling from the package system with bundled fonts.

== Section with Styled Components

Callouts and other components are imported from the package.
```

### Creating Custom Templates

1. Create a `.typ` file in your template directory
2. Import the typstwriter library (paths are automatically set during template creation):

```typst
#import "/home/user/.local/share/nvim/typstwriter/package/lib.typ": *

#metadata((
  title: "My Custom Document",
  type: "custom",
  date: "2025-08-16",
  tags: ("custom", "template"),
))

#show: note_template

= My Custom Document

This template uses the XDG-installed package system with bundled fonts.

== Features

- Professional typography with Iosevka NF and Hack Nerd Font
- Consistent styling across all documents  
- Automatic metadata display
- Cross-platform font compatibility
```

### Package Components

The XDG-installed typstwriter package provides:

- **Main library** (`lib.typ`): Complete entry point with all functions and templates
- **Core styles** (`core/base.typ`): Base typography, spacing, and layout with bundled fonts
- **Document templates** (`core/document.typ`): Note, meeting, and article templates
- **Metadata handling** (`core/metadata.typ`): Smart metadata parsing and display
- **Bundled fonts** (`fonts/`): Professional font files (~32MB) for consistent typography

## Requirements

- **Neovim** >= 0.7.0
- **Typst binary** - Install from [typst.app](https://typst.app) or your package manager
- **PDF viewer** - Any system PDF viewer (`xdg-open`, `open`, `start`)

### Fonts (Bundled)

Typstwriter includes professional fonts (~32MB) for consistent cross-platform typography:
- **Iosevka Nerd Font** - Primary proportional and monospace fonts
- **Hack Nerd Font Mono** - Alternative monospace font with excellent readability
- **Noto Color Emoji** - Full color emoji support

**No font installation required!** The plugin automatically provides fonts to Typst via the `--font-path` system, ensuring documents render identically across Linux, macOS, and Windows.

## Troubleshooting

### Typst binary not found
```bash
# Install Typst
# On macOS:
brew install typst

# On Linux (cargo):
cargo install --git https://github.com/typst/typst --tag v0.10.0 typst-cli

# Or download from: https://github.com/typst/typst/releases
```

### Check plugin status
```vim
:TypstWriterStatus        # Shows compilation status and system requirements
:TypstWriterPackageStatus # Shows package installation status
```

### Package not installed
- Run `:TypstWriterSetup` to install the XDG package system
- Check `:TypstWriterPackageStatus` for installation status  
- Package should be installed to `~/.local/share/nvim/typstwriter/` (Linux) or equivalent XDG directories

### Template not found
- Run `:TypstWriterSetupTemplates` to install templates
- Check that templates are in the correct directory (`template_dir`)
- Verify templates have proper absolute imports to XDG directories
- Run `:TypstWriterTemplates` to list available templates

### Import errors in templates
- Ensure package is installed with `:TypstWriterPackageStatus`
- Templates should use absolute imports like `/home/user/.local/share/nvim/typstwriter/package/lib.typ`
- Import paths are automatically set during template creation
- Re-run `:TypstWriterSetup` if package needs updating

### Font Issues (Rare)

The bundled font system should work automatically. If you encounter font warnings:

```bash
# Check if Typst can see the bundled fonts
typst fonts | grep -E "(Iosevka|Hack|Noto)"

# Should show entries like:
# - Iosevka NF (bundled)
# - Hack Nerd Font Mono (bundled) 
# - Noto Color Emoji (bundled)
```

If fonts aren't loading:
1. Check `:TypstWriterPackageStatus` - fonts should be installed to XDG directories
2. Verify the fonts directory exists: `~/.local/share/nvim/typstwriter/fonts/`
3. Re-run `:TypstWriterSetup` to reinstall fonts
4. Font warnings in compilation output are often harmless fallback messages

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Future Vision: Personal Knowledge System

**typstwriter.nvim** is evolving beyond templating into a comprehensive **Personal Knowledge System (PKS)** that rivals Obsidian while remaining entirely terminal-based.

### Planned Features

#### **Phase 1: Intelligent Linking**
```vim
:TWriterLink          " Interactive document linking with fuzzy search
:TWriterFollow        " Follow links under cursor with navigation history
:TWriterBacklinks     " Discover and navigate backlinks
```

#### **Phase 2: Smart Search & Discovery**
```vim
:TWriterSearch @frontend status:todo    " Multi-criteria metadata search
:TWriterBrowse                          " Visual document browser with filtering
:TWriterTags                            " Tag management and renaming
```

#### **Phase 3: Visual Knowledge Graphs**
```vim
:TWriterGraph         " Generate beautiful relationship maps in Typst
:TWriterInsights      " AI-powered knowledge base analysis
```

#### **Phase 4: Local AI Integration** 🤖
```vim
:TWriterChat          " Chat with your notes using local LLM (Ollama)
:TWriterAINew         " AI-assisted document creation
:TWriterAIEnhance     " Smart content suggestions and improvements
:TWriterAISearch      " Semantic search through your knowledge base
```

**Privacy-First AI:** All AI features use local models (Ollama, llamafile) - your data never leaves your machine.

### The Vision

Imagine the **best aspects** of:
- **Obsidian's** linking and graph views
- **Notion's** AI writing assistance  
- **Roam's** bi-directional connections
- **LaTeX's** professional typesetting

...but **entirely in your terminal** with **local AI** and **no privacy compromises**.

**See the full roadmap**: [ROADMAP.md](./ROADMAP.md)

---

## Acknowledgments

- [Typst](https://typst.app) - The amazing typesetting system that makes this possible
- [Neovim](https://neovim.io) - The extensible text editor that powers the experience  
- [Ollama](https://ollama.ai) - Making local AI accessible for the future PKS features
- The Neovim community for excellent plugin development patterns
- The terminal-first computing philosophy that refuses to compromise
