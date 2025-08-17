---
layout: default
title: Development
---

# Development Documentation

Welcome to the development documentation for typstwriter.nvim. This section contains technical information for contributors and advanced users.

## Architecture Overview

typstwriter.nvim is designed as a **metadata-driven Typst writing system** with a modular architecture:

- **Terminal-native**: Everything stays in Neovim
- **Metadata-first**: Uses native Typst `#metadata()` functions
- **Modular design**: Clean separation of concerns
- **Progressive enhancement**: Built for future PKS (Personal Knowledge System) features

## Development Resources

### Core Architecture
- **[Package Design](PACKAGE-DESIGN.html)** - Overall plugin architecture and design decisions
- **[Local Package Architecture](LOCAL-PACKAGE-ARCHITECTURE.html)** - Local development setup
- **[Package Setup](PACKAGE-SETUP.html)** - Development environment configuration

### Command System
- **[CLI Command Design](CLI-COMMAND-DESIGN.html)** - New CLI-style command structure
- **[Template Analysis](TEMPLATE-ANALYSIS.html)** - Template system deep dive

## Module Structure

```
lua/typstwriter/
├── init.lua          # Main entry point, plugin setup, command creation
├── config.lua        # Configuration management with defaults and validation
├── templates.lua     # Template discovery, validation, and document creation
├── compiler.lua      # Typst compilation, PDF opening, status checking
├── metadata.lua      # Native Typst metadata parsing using `typst query`
├── utils.lua         # Utility functions (filename generation, system checks)
└── linking.lua       # Future: Document linking system
```

## Development Workflow

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/gl1tchc0d3r/typstwriter.nvim.git
cd typstwriter.nvim

# Install development dependencies
make install-deps

# Run tests
make test

# Check code quality
make check
```

### Development Commands

```bash
# Testing
make test              # Run passing integration tests (7 tests)
make test-all          # Run all tests (includes unit tests)
make test-coverage     # Generate coverage report
make test-watch        # Watch mode for development

# Code Quality
make format            # Format code with StyLua
make lint              # Lint with luacheck
make format-check      # Check formatting without changes
make check             # Run all quality checks

# CI/CD
make ci                # Full CI pipeline locally

# Shortcuts
make f                 # format
make l                 # lint  
make c                 # check
make t                 # test
make tc                # test-coverage
```

## Testing Strategy

typstwriter.nvim uses a **pragmatic two-tier testing approach**:

### Production Tests (`spec/integration_spec.lua`)
- **Status**: 7 passing tests, 0 failures - **production ready**
- **Coverage**: Plugin setup, commands, config, utilities, compiler
- **Used by**: CI/CD pipeline for reliability assurance
- **Command**: `make test`

### Development Tests (`spec/*_spec.lua`)
- **Status**: ~37 successes, some incomplete - **development aid**
- **Purpose**: Detailed unit coverage for individual modules
- **Note**: Some tests need updates to match evolved API
- **Command**: `make test-all`

## Key Design Patterns

### Metadata-First Approach
All templates use `#metadata((...))` blocks parsed via `typst query`:

```typst
#metadata((
  type: "note",
  title: "My Document",
  date: "2024-01-15",
  tags: ("example",),
))
```

### Configuration System
- Deep merge of user config with defaults
- Path expansion with `vim.fn.expand()`
- Directory creation with validation
- Metadata validation against required fields

### Template Discovery Process
1. **Scan** `template_dir` for `.typ` files
2. **Query** each file using `typst query` for metadata
3. **Validate** required fields (`type`, `title`)
4. **Build** template registry with fallback handling

## Future Architecture (PKS Evolution)

The plugin is designed to evolve into a Personal Knowledge System:

### Phase 1: Enhanced Linking
- Document linking with fuzzy search
- Link navigation with history
- Backlink discovery

### Phase 2: Metadata-Driven Search
- Multi-criteria search
- Document browser with metadata columns
- Tag management and renaming

### Phase 3: Visual Relationship Mapping
- Typst-generated network graphs
- Knowledge base insights and analytics
- Auto-generated relationship sections

### Phase 4: Local AI Integration
- Local LLM chat interface
- AI-assisted document creation
- Content enhancement and suggestions

## Contributing

### Code Style
- **StyLua** formatting with 120 character line width
- **Luacheck** linting with Neovim globals
- **Documentation** strings for all public functions
- **Error handling** with user-friendly notifications

### Testing Requirements
- **Integration tests must pass**: `make test` should always succeed
- **Quality checks required**: `make check` must pass
- **CI pipeline compliance**: `make ci` validates full workflow

### Branch Protection
- **Pull requests target staging branch** (never main directly)
- **Main branch protected** for production releases
- **CI checks required** before merge approval

## Getting Help

- **Issues**: Report bugs or request features on GitHub
- **Documentation**: This development section contains detailed technical information
- **Code**: The codebase is well-documented with inline comments

---

*typstwriter.nvim - Built with quality, designed for the future of knowledge management.*
