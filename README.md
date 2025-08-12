# typstwriter.nvim

> A complete Typst writing system for Neovim - from beautiful templates to intelligent personal knowledge management

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/gl1tchc0d3r/typstwriter.nvim/workflows/CI/badge.svg)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![Tests](https://img.shields.io/github/actions/workflow/status/gl1tchc0d3r/typstwriter.nvim/ci.yml?branch=main&label=tests)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![codecov](https://codecov.io/gh/gl1tchc0d3r/typstwriter.nvim/branch/main/graph/badge.svg)](https://codecov.io/gh/gl1tchc0d3r/typstwriter.nvim)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![Typst](https://img.shields.io/badge/Typst-compatible-blue.svg)](https://typst.app)

![Document Example](./assets/example-document.png)

*Professional document output with automated status badges, smart tag coloring, and beautiful typography - all generated from simple templates.*

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

### Template System
- **Smart templates** with automatic metadata handling (status, tags, properties)
- **Dynamic template discovery** - automatically finds all `.typ` templates
- **Consistent styling** with professional color schemes and typography
- **Status badges** with deterministic coloring (same status = same color always)
- **Tag system** supporting special characters, emojis, and automatic color assignment

### Workflow Integration  
- **One-command document creation** from templates
- **Integrated compilation** - compile to PDF and open instantly
- **Auto-compilation** on save with live PDF refresh
- **Smart file naming** with customizable formats and conflict prevention
- **Cross-platform** support (Linux, macOS, Windows)

### Professional Output
- **Beautiful typography** with proper heading hierarchy and spacing
- **Code highlighting** for inline and block code with syntax support
- **Professional links** with elegant underlines and hover effects  
- **Consistent icons** using Nerd Fonts for visual clarity
- **Metadata boxes** for structured document properties

## Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "gl1tchc0d3r/typstwriter.nvim",
  ft = "typst",
  cmd = { "TWriterNew", "TWriterCompile", "TWriterOpen", "TWriterBoth" },
  keys = {
    { "<leader>tn", "<cmd>TWriterNew<cr>", desc = "New document from template" }
  },
  config = function()
    require('typstwriter').setup({
      notes_dir = "~/Documents/notes",
    })
  end
}
```

### With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'gl1tchc0d3r/typstwriter.nvim',
  config = function()
    require('typstwriter').setup()
  end
}
```

## Configuration

### Default Configuration

```lua
require('typstwriter').setup({
  -- Directory settings
  notes_dir = "~/Documents/notes",
  template_dir = nil, -- defaults to notes_dir/typst-templates
  
  -- File naming
  filename_format = "{name}.{code}.typ", -- {name}, {code}, {date}
  code_length = 6,
  
  -- Compilation settings
  auto_compile = false,
  open_after_compile = true,
  
  -- Key mappings (set to false to disable)
  keymaps = {
    new_document = "<leader>tn",
    compile = "<leader>tp",
    open_pdf = "<leader>to", 
    compile_and_open = "<leader>tb",
    pdf_generate = "<leader>pd",  -- Alternative short mapping
    pdf_open = "<leader>po",      -- Alternative short mapping
  },
  
  -- UI preferences
  use_modern_ui = true, -- Use vim.ui.select/input when available
  
  -- Notifications
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO,
  }
})
```

### Custom Configuration Example

```lua
require('typstwriter').setup({
  notes_dir = "~/my-notes",
  template_dir = "~/my-notes/templates",
  filename_format = "{name}-{date}.typ",
  auto_compile = true,
  keymaps = {
    new_document = "<leader>nn",
    compile = "<leader>cc",
    open_pdf = "<leader>oo",
    compile_and_open = false, -- Disable this keymap
  }
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:TWriterNew` | Create new document from template |
| `:TWriterCompile` | Compile current document to PDF |
| `:TWriterOpen` | Open PDF of current document |
| `:TWriterBoth` | Compile and open PDF |
| `:TWriterStatus` | Show compilation status and system info |
| `:TWriterTemplates` | List available templates |

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
| `<leader>tn` | Normal | Create new document |
| `<leader>tp` | Normal (Typst files) | Compile to PDF |
| `<leader>to` | Normal (Typst files) | Open PDF |
| `<leader>tb` | Normal (Typst files) | Compile and open |
| `<leader>pd` | Normal (Typst files) | Generate PDF |
| `<leader>po` | Normal (Typst files) | Open PDF |

### Basic Workflow

1. **Create a new document**: Press `<leader>tn` or run `:TWriterNew`
2. **Select template**: Choose from dynamically discovered templates
3. **Enter document name**: Provide a name for your document
4. **Edit**: The new file opens automatically
5. **Compile**: Press `<leader>tp` or run `:TWriterCompile`
6. **View**: Press `<leader>to` or run `:TWriterOpen` to view the PDF

## Templates

### Template Structure

Templates should be `.typ` files in your template directory. The plugin:
- Discovers all `.typ` files automatically
- Skips `base.typ` (reserved for shared utilities)
- Capitalizes template names for display

### Example Template Directory

```
typst-templates/
├── base.typ       # Shared styles and utilities (ignored by plugin)
├── meeting.typ    # Meeting notes template
├── project.typ    # Project documentation template
├── article.typ    # Article template
└── report.typ     # Report template
```

### Creating Custom Templates

1. Create a `.typ` file in your template directory
2. Use the included `base.typ` for consistent styling:

```typst
#import "typst-templates/base.typ": base

#show: base.with(
  title: "My Custom Template",
  date: datetime.today(),
  doc_type: "custom",
  status: "draft",
  tags: ("custom", "template"),
  properties: (
    ("Author", ""),
    ("Version", "1.0"),
    ("Category", "General"),
  ),
)

= #nerd_icon("") Main Section

// Your template content here
// Use nerd_icon() function for consistent icons:
// #nerd_icon("") for projects
// #nerd_icon("") for meetings
// #nerd_icon("") for notes
// #nerd_icon("") for action items
// #nerd_icon("") for calendar events
```

### Using Icons in Templates

The base template provides a `nerd_icon()` function for consistent icon display:

```typst
// Use icons in headings
= #nerd_icon("") Meeting Agenda
= #nerd_icon("") Discussion Points
= #nerd_icon("") Action Items

// Or in content
Project status: #nerd_icon("") In Progress
```

Common icon examples:
- `` - Projects and work
- `` - Meetings and discussions  
- `` - Tasks and action items
- `` - Calendar and dates
- `` - Notes and documentation
- `` - Ideas and concepts
- `` - Settings and configuration
- `` - Files and documents

## Requirements

- **Neovim** >= 0.7.0
- **Typst binary** - Install from [typst.app](https://typst.app) or your package manager
- **PDF viewer** - Any system PDF viewer (`xdg-open`, `open`, `start`)
- **Nerd Font** (recommended) - For enhanced visual appearance with icons
  - Primary font: Iosevka Nerd Font (NFP/NFM variants)
  - Fallback fonts: Hack Nerd Font, DejaVu Sans/Mono, or any Nerd Font
  - Install from: https://www.nerdfonts.com/font-downloads
  - Templates use professional font stacks for optimal rendering

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
:TWriterStatus  # Shows compilation status and system requirements
```

### Template not found
- Ensure templates are in the correct directory (`template_dir`)
- Check that files have `.typ` extension
- Run `:TWriterTemplates` to list available templates

### Font/Icon Issues
```bash
# Check available fonts in Typst
typst fonts

# Look for Nerd Fonts (should see entries like:)
# - Iosevka NFP (proportional)
# - Iosevka NFM (monospace)
# - Hack Nerd Font
# - Symbols Nerd Font
```

If icons don't display correctly:
1. Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com)
2. Verify the font is available with `typst fonts`
3. The templates use "Iosevka NFP/NFM" by default with fallbacks
4. You can modify the font stacks in `base.typ` to use different fonts

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
