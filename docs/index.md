---
layout: default
title: Home
---

# typstwriter.nvim

A metadata-driven Typst writing system for Neovim that serves as a complete terminal-native document creation and knowledge management tool.

## Core Philosophy

- **Terminal-native**: Everything stays in Neovim, no GUI dependencies
- **Metadata-driven**: Uses native Typst `#metadata()` functions for document properties
- **Privacy-first**: Local processing, your data stays local
- **Progressive enhancement**: Starting with templates, evolving toward AI-assisted knowledge management

---

## 📚 Documentation

| Section | Description |
|---------|-------------|
| **[📦 Installation](installation.html)** | Get typstwriter.nvim up and running |
| **[⚙️ Configuration](configuration.html)** | Customize your setup and preferences |
| **[💻 Commands](commands.html)** | Learn all available commands |
| **[📝 Templates](templates.html)** | Work with Typst templates |
| **[🔧 Development](development.html)** | Technical docs for contributors |

---

## Quick Start

1. **[Install](installation.html)** the plugin and Typst binary
2. **[Configure](configuration.html)** your preferences (optional)
3. **Run one-time setup** with `:TypstWriter setup`
4. **Create your first document** with `:TypstWriter new`
5. **Compile and view** with `:TypstWriter both`

## Features

### Current Features
- **Template System**: Create documents from Typst templates with native metadata
- **Compilation**: Compile Typst documents to PDF with status checking
- **Cross-platform**: Works on Linux, macOS, and Windows
- **Configuration**: Deep merge configuration system with validation

### Planned Features (PKS Evolution)
- **Document Linking**: Fuzzy search and backlink discovery
- **Metadata Search**: Multi-criteria search across your knowledge base
- **Visual Graphs**: Network visualization of document relationships
- **Local AI**: Privacy-first AI assistance for writing and organization

## Development

This plugin is actively developed with a focus on quality and reliability:

- **Testing**: 7 passing integration tests, 0 failures
- **Code Quality**: 0 lint warnings, perfect formatting
- **Documentation**: Comprehensive guides and API reference

→ [Development Documentation](development/)

## Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/gl1tchc0d3r/typstwriter.nvim/issues)
- **Documentation**: Browse these docs for detailed information
- **Community**: Star the repo if you find it useful!

---

*typstwriter.nvim - Transforming how you write and organize knowledge in the terminal.*
