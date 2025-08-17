# typstwriter.nvim

> A metadata-driven Typst writing system for Neovim that serves as a complete terminal-native document creation and knowledge management tool.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/gl1tchc0d3r/typstwriter.nvim/workflows/CI/badge.svg)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![Tests](https://img.shields.io/github/actions/workflow/status/gl1tchc0d3r/typstwriter.nvim/ci.yml?branch=main&label=tests)](https://github.com/gl1tchc0d3r/typstwriter.nvim/actions)
[![codecov](https://codecov.io/github/gl1tchc0d3r/typstwriter.nvim/graph/badge.svg?token=J3ZM26AFGP)](https://codecov.io/github/gl1tchc0d3r/typstwriter.nvim)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-green.svg)](https://neovim.io)
[![Typst](https://img.shields.io/badge/Typst-compatible-blue.svg)](https://typst.app)

## 📚 Documentation

**Complete documentation is available at: https://gl1tchc0d3r.github.io/typstwriter.nvim/**

- 📦 **[Installation](https://gl1tchc0d3r.github.io/typstwriter.nvim/installation.html)** - Get up and running quickly
- ⚙️ **[Configuration](https://gl1tchc0d3r.github.io/typstwriter.nvim/configuration.html)** - Customize to your preferences  
- 💻 **[Commands](https://gl1tchc0d3r.github.io/typstwriter.nvim/commands.html)** - Available commands and usage
- 📝 **[Templates](https://gl1tchc0d3r.github.io/typstwriter.nvim/templates.html)** - Working with Typst templates
- 🔧 **[Development](https://gl1tchc0d3r.github.io/typstwriter.nvim/development.html)** - Contributing and development info

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
- Readable, programmable markup that doesn't sacrifice functionality
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

## What It Does

**typstwriter.nvim** transforms Typst templates into structured documents using native Typst metadata, providing a complete terminal-native writing system:

### Core Features
- **📝 Template-based document creation** - One command creates professional documents
- **🎨 Metadata-driven workflow** - Uses native Typst `#metadata()` functions  
- **📦 Package-based architecture** - Self-contained system with bundled fonts (~32MB)
- **⚡ Integrated compilation** - Compile to PDF and open with a single keystroke
- **🔧 Terminal-native** - Everything stays in Neovim, no GUI dependencies
- **🎯 Cross-platform** - Works on Linux, macOS, and Windows

### Template System
- **Professional templates** - Notes, meetings, articles, reports
- **Consistent styling** - Shared typography and themes across documents
- **Smart metadata** - Automatic dates, tags, and document properties
- **Easy customization** - Create your own templates with package imports

## Quick Start

### 1. Install Requirements
```bash
# Install Typst binary
brew install typst          # macOS
pacman -S typst             # Arch Linux
# Or download from: https://typst.app
```

### 2. Install Plugin (lazy.nvim example)
```lua
{
  "gl1tchc0d3r/typstwriter.nvim",
  ft = "typst",
  config = function()
    require('typstwriter').setup()
  end
}
```

### 3. One-Time Setup
```vim
:TypstWriter setup    " Installs package system and templates
```

### 4. Create Your First Document
```vim
:TypstWriter new      " Choose template, enter title, start writing!
```


## Basic Usage

### Core Commands

typstwriter.nvim uses a unified CLI-style command structure:

| Command | Description |
|---------|-------------|
| `:TypstWriter new` | Create new document from template |
| `:TypstWriter compile` | Compile current document to PDF |
| `:TypstWriter open` | Open PDF of current document |
| `:TypstWriter both` | Compile and open PDF |
| `:TypstWriter status` | Show system status |
| `:TypstWriter setup` | Complete system setup |
| `:TypstWriter templates list` | List available templates |
| `:TypstWriter package status` | Show package status |

**Tab completion available at every level** - try `:TypstWriter <Tab>` to explore!

### Default Keymaps

#### Main Commands (Always Available)
| Key | Action |
|-----|--------|
| `<leader>Tn` | Create new document |
| `<leader>Ts` | Setup package system |
| `<leader>Th` | Show help |
| `<leader>Ttl` | List templates |
| `<leader>Tps` | Package status |
| `<leader>Tpi` | Package install |

#### Document Operations (Typst Files Only)
| Key | Action |
|-----|--------|
| `<leader>Tdc` | Compile to PDF |
| `<leader>Tdo` | Open PDF |
| `<leader>Tdb` | Compile and open |
| `<leader>Tds` | Document status |

**For detailed configuration, commands, templates, and troubleshooting, see the [complete documentation](https://gl1tchc0d3r.github.io/typstwriter.nvim/).**

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
