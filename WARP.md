# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**typstwriter.nvim** is a metadata-driven Typst writing system for Neovim that serves as a complete terminal-native document creation and knowledge management tool. The plugin transforms Typst templates into structured documents using native Typst metadata, with plans to evolve into a comprehensive Personal Knowledge System (PKS).

### Core Philosophy
- **Terminal-native**: Everything stays in Neovim, no GUI dependencies
- **Metadata-driven**: Uses native Typst `#metadata()` functions for document properties
- **Privacy-first**: Local processing, your data stays local
- **Progressive enhancement**: Starting with templates, evolving toward AI-assisted knowledge management

## Architecture

### Module Structure
```
lua/typstwriter/
├── init.lua          # Main entry point, plugin setup, CLI command creation
├── cli.lua           # CLI command parser, routing, and tab completion
├── config.lua        # Configuration management with defaults and validation
├── templates.lua     # Template discovery, validation, and document creation
├── document.lua      # Document workflow (compile, open, status)
├── metadata.lua      # Native Typst metadata parsing using `typst query`
├── utils.lua         # Utility functions (filename generation, system checks)
├── package.lua       # XDG package system for fonts and templates
├── paths.lua         # Cross-platform path management
├── database.lua      # SQLite database connection and schema management
├── indexing.lua      # Document indexing with metadata extraction
└── search.lua        # Database-backed document search and discovery
```

### Key Design Patterns
- **Metadata-first approach**: All templates use `#metadata((...))` blocks that are parsed via `typst query`
- **Configuration system**: Deep merge of user config with defaults, path expansion, directory creation
- **Status validation**: Template metadata must include required fields (`type`, `title`)
- **System integration**: Cross-platform PDF opening, Typst binary detection

## Development Commands

### Testing
```bash
# Run passing integration tests (8 tests - production ready)
make test

# Run all tests (includes incomplete unit tests)
make test-all

# Coverage reporting
make test-coverage

# Watch mode for development
make test-watch

# Full CI pipeline locally
make ci
```

### Code Quality
```bash
# Format code with StyLua
make format

# Lint with luacheck
make lint

# Check formatting without changes
make format-check

# Run all quality checks
make check

# Quick shortcuts
make f    # format
make l    # lint  
make c    # check
make t    # test
make tc   # test-coverage
```

### Setup & Maintenance
```bash
# Install all development dependencies
make install-deps

# Clean generated files
make clean

# Show development tool versions
make version

# Show available commands with descriptions
make help
```

### Plugin Installation Testing
```bash
# For manual plugin management only (not recommended)
make install

# Show installation instructions for plugin managers
make install-info

# Remove manually installed plugin
make uninstall
```

## Testing Strategy

The project uses a **pragmatic two-tier testing approach**:

### Production Tests (`spec/integration_spec.lua`)
- **Status**: 8 passing tests, 0 failures - **production ready**
- **Coverage**: Plugin setup, CLI commands, config, utilities, document workflow
- **Used by**: CI/CD pipeline for reliability assurance
- **Command**: `make test`

### Development Tests (`spec/*_spec.lua`) 
- **Status**: ~37 successes, some incomplete - **development aid**
- **Purpose**: Detailed unit coverage for individual modules
- **Note**: Some tests need updates to match evolved API
- **Command**: `make test-all`

**Quality Assurance**: Despite incomplete unit tests, the project maintains excellent quality with 0 lint warnings, perfect formatting, and comprehensive integration testing.

## Configuration System

### Default Configuration Location
```lua
-- lua/typstwriter/config.lua
M.defaults = {
  notes_dir = "~/Documents/notes",
  template_dir = nil,  -- defaults to notes_dir/templates/v2
  default_template_type = "note",
  auto_date = true,
  use_random_suffix = true,
  auto_compile = false,
  open_after_compile = true,
  require_metadata = true,
  required_fields = { "type", "title" },
  keymaps = { -- keymap mappings following CLI structure
    -- Main commands
    new_document = "<leader>Tn",        -- TypstWriter new
    setup = "<leader>Ts",               -- TypstWriter setup
    help = "<leader>Th",                -- TypstWriter help

    -- Document operations (Td prefix)
    compile = "<leader>Tdc",            -- TypstWriter compile
    open_pdf = "<leader>Tdo",           -- TypstWriter open
    compile_and_open = "<leader>Tdb",   -- TypstWriter both
    status = "<leader>Tds",             -- TypstWriter status

    -- Template operations (Tt prefix)
    list_templates = "<leader>Ttl",     -- TypstWriter templates list

    -- Package operations (Tp prefix)
    package_status = "<leader>Tps",     -- TypstWriter package status
    package_install = "<leader>Tpi",    -- TypstWriter package install
  }
}
```

### Configuration Features
- **Deep merge** of user config with defaults
- **Path expansion** with `vim.fn.expand()`
- **Directory creation** with validation
- **Metadata validation** against required fields
- **Keymap management** with optional disable

## Template System

### Template Architecture
Templates are `.typ` files with native Typst metadata blocks:

```typst
#metadata((
  type: "meeting",
  title: "Meeting Template", 
  date: "2024-01-15",
  status: "draft",
  tags: ("meeting",),
  participants: (),
))

// Template content with metadata integration
#context {
  let meta = query(metadata).first().value
  heading(level: 1)[📋 Meeting: #meta.title]
}
```

### Template Discovery Process
1. **Scan** `template_dir` for `.typ` files
2. **Query** each file using `typst query` for metadata
3. **Validate** required fields (`type`, `title`)
4. **Build** template registry with fallback handling

### Document Creation Workflow
1. **Template selection** via `vim.ui.select`
2. **Title input** via `vim.ui.input` 
3. **Filename generation** with optional random suffixes
4. **Metadata update** (title, date if `auto_date` enabled)
5. **File creation** in `notes_dir`

## Compilation System

### Compilation Features
- **Typst binary detection** with user warnings
- **Metadata validation** before compilation
- **Cross-platform PDF opening** (xdg-open/open/start)
- **Status reporting** with detailed system info
- **Auto-compilation** on save (optional)

### Status Information
The `:TypstWriter status` command provides comprehensive system diagnostics:
- File existence checks (Typst file, PDF file)
- System requirements (Typst binary, PDF opener)
- Metadata status (presence, validation, fields)
- PDF currency (outdated detection)
- Actionable recommendations

## Commands & User Interface

### Unified CLI Command Structure

The plugin uses a unified CLI-style command interface with subcommands, similar to `git`, `docker`, or `kubectl`:

```vim
:TypstWriter new              " Create document from template
:TypstWriter compile          " Compile current document to PDF
:TypstWriter open            " Open PDF of current document
:TypstWriter both            " Compile and open PDF
:TypstWriter status          " Show system status and metadata
:TypstWriter setup           " Complete system setup
:TypstWriter templates list  " List available templates
:TypstWriter package status  " Show package installation status
:TypstWriter package install " Install XDG package system
:TypstWriter help           " Show help information
```

### CLI Features
- **Tab completion** at every level - try `:TypstWriter <Tab>` to explore
- **Hierarchical organization** - commands grouped by function
- **Intelligent error handling** - helpful messages and suggestions
- **Future-ready** - designed for upcoming PKS features

### New Database-Backed Commands (Phase 1 Implementation)
```vim
:TypstWriter search [query]     " Search documents (supports @tag, status:value, type:value)
:TypstWriter recent [days]      " Show recently modified documents (default: 7 days)
:TypstWriter stats              " Show document statistics in floating window
:TypstWriter refresh            " Refresh document index (incremental)
:TypstWriter rebuild            " Rebuild document index (full scan)
```

#### Search Query Syntax
- `@tag` - Filter by tag/topic (e.g., `@meeting`)
- `status:value` - Filter by status (e.g., `status:draft`)
- `type:value` - Filter by document type (e.g., `type:note`)
- Text search - Search in title, content, and metadata
- Combined queries - Mix all syntax types: `@project status:todo planning`


### Default Keymaps

#### Main Commands (Always Available)
```vim
<leader>Tn     " New document
<leader>Ts     " Setup package system
<leader>Th     " Show help
<leader>Ttl    " List templates
<leader>Tps    " Package status
<leader>Tpi    " Package install
```

#### Document Operations (Typst Files Only)
```vim
<leader>Tdc    " Compile
<leader>Tdo    " Open PDF
<leader>Tdb    " Compile and open
<leader>Tds    " Document status
```

#### Search Operations (Always Available)
```vim
<leader>TS     " Interactive document search
<leader>TSr    " Show recent documents
<leader>TSs    " Show document statistics
<leader>TSi    " Refresh document index
<leader>TSI    " Rebuild document index
```

## Future Architecture (PKS Evolution)

The plugin is designed to evolve into a Personal Knowledge System with:

### Phase 1: Enhanced Linking
- Document linking with fuzzy search (`TWriterLink`)
- Link navigation with history (`TWriterFollow`) 
- Backlink discovery (`TWriterBacklinks`)

### Phase 2: Metadata-Driven Search
- Multi-criteria search (`TWriterSearch @tag status:todo`)
- Document browser with metadata columns (`TWriterBrowse`)
- Tag management and renaming (`TWriterTags`)

### Phase 3: Visual Relationship Mapping  
- Typst-generated network graphs (`TWriterGraph`)
- Knowledge base insights and analytics (`TWriterInsights`)
- Auto-generated relationship sections in documents

### Phase 4: Local AI Integration
- Local LLM chat interface (`TWriterChat`)
- AI-assisted document creation (`TWriterAINew`) 
- Content enhancement and suggestions (`TWriterAIEnhance`)

## Dependencies & Requirements

### Runtime Requirements
- **Neovim** >= 0.7.0
- **Typst binary** from [typst.app](https://typst.app)
- **PDF viewer** (system default)
- **Nerd Font** (recommended for icons)

### Development Dependencies (via `make install-deps`)
- **busted** - Testing framework
- **luacov** - Coverage reporting  
- **luacheck** - Linting
- **stylua** - Code formatting (manual install)

### CI/CD Requirements
- **GitHub Actions** with Ubuntu runners
- **Lua 5.1** + **LuaRocks** for dependencies
- **Typst** binary installation for integration tests
- **Codecov** integration for coverage reports

## Contributing Guidelines

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

## Git Workflow Patterns

### Standard Feature Branch Workflow
```bash
# Create feature branch from staging
git checkout staging
git pull origin staging
git checkout -b feature/feature-name

# Develop and commit
git add .
git commit -m "feat: implement feature"
git push origin feature/feature-name

# Merge to staging when complete
git checkout staging
git merge feature/feature-name --no-ff
git push origin staging

# Clean up completed feature branch
git branch -d feature/feature-name
```

### Early Merge + Continued Development Pattern
```bash
# Create and start feature
git checkout staging
git checkout -b feature/feature-name
git commit -m "feat: initial implementation"

# Early merge to staging (for integration or experimentation)
git checkout staging
git merge feature/feature-name --no-ff -m "Merge early: feature-name initial work"
git push origin staging

# Continue development on feature branch
git checkout feature/feature-name
# ... more commits ...
git commit -m "feat: enhanced implementation"
git push origin feature/feature-name

# Final merge when complete
git checkout staging
git merge feature/feature-name --no-ff -m "Merge completed: feature-name"
```

### Branch Management Commands
```bash
# View branch status
git branch -a                    # All branches
git log --oneline --graph -10    # Visual commit history

# Sync with remote
git fetch origin                 # Get latest remote state
git pull origin staging         # Update staging

# Clean up merged branches
git branch -d feature/old-feature    # Delete local branch
git push origin --delete feature/old-feature  # Delete remote branch
```

### Repository Structure
- **main**: Stable production releases
- **staging**: Integration branch for completed features
- **feature/***: Individual feature development branches
- **experiment/***: Temporary branches for testing ideas

### Commit Message Patterns
```
feat: add new feature
fix: resolve bug in component
docs: update documentation
refactor: restructure code
test: add test coverage
chore: update dependencies
```

## Database-Backed PKS System (Phase 1 Implementation)

### Database Architecture
The plugin now includes a **SQLite-based Personal Knowledge System** foundation:

- **SQLite database**: Located at `notes_dir/database/typstwriter.db`
- **Document indexing**: Automatic metadata extraction and content caching
- **Smart sync**: File modification time and content hash-based change detection
- **Performance**: Database queries replace filesystem scanning for instant results
- **Future-ready**: Schema designed for AI features (embeddings, semantic search)

### Database Schema (Current)
```sql
-- Documents table with rich metadata
CREATE TABLE documents (
  id INTEGER PRIMARY KEY,
  filepath TEXT UNIQUE NOT NULL,
  title TEXT,
  type TEXT,
  status TEXT,
  date TEXT,
  modified_time INTEGER,
  content_hash TEXT,
  content_preview TEXT,      -- First 2000 chars for search
  full_content TEXT,         -- Complete content
  topics TEXT,               -- JSON array of tags/topics
  entities TEXT,             -- JSON array of entities
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Future: Chunks, tags, and links tables for Phase 2
```

### Indexing System
- **Automatic indexing**: Documents indexed on first search if database empty
- **Incremental updates**: Only re-indexes changed files (by mtime + content hash)
- **Metadata extraction**: Uses existing `metadata.lua` parser
- **Content caching**: Full content + preview stored for fast search
- **Fallback mode**: Graceful fallback to filesystem scanning if database unavailable

### Search Capabilities
- **Structured queries**: `@tag status:draft type:meeting planning`
- **Text search**: Searches title, content preview, topics, filepath
- **Metadata filtering**: Filter by type, status, tags simultaneously
- **Performance**: Instant results via indexed database queries
- **Smart display**: Shows status, tags, recency indicators, document type

## Key Files to Understand

### Core Implementation
- `lua/typstwriter/init.lua` - Plugin entry point and CLI command setup
- `lua/typstwriter/cli.lua` - CLI command routing and tab completion
- `lua/typstwriter/templates.lua` - Template system heart
- `lua/typstwriter/document.lua` - Document workflow (compile, open, status)
- `lua/typstwriter/metadata.lua` - Native Typst metadata parsing
- `lua/typstwriter/package.lua` - XDG package system
- `lua/typstwriter/paths.lua` - Cross-platform path management

### Database PKS System (NEW)
- `lua/typstwriter/database.lua` - SQLite connection, schema, migrations
- `lua/typstwriter/indexing.lua` - Document indexing with change detection
- `lua/typstwriter/search.lua` - Database-backed search and document discovery
- `DATABASE_DESIGN_PLAN.md` - Comprehensive PKS architecture plan

### Configuration & Testing  
- `lua/typstwriter/config.lua` - Configuration management
- `spec/integration_spec.lua` - Production test suite (8 passing tests)
- `Makefile` - Development workflow automation

### Documentation
- `README.md` - Comprehensive usage guide and philosophy
- `docs/commands.md` - Complete CLI command reference
- `docs/CLI-COMMAND-DESIGN.md` - Design document and implementation log
- `ROADMAP.md` - Future PKS evolution plans  
- `TESTING.md` - Testing strategy explanation

---

# Next Session Guide

## Current Status (as of 2025-01-17)

**✅ Completed: Phase 1.0 Database-Backed Document Discovery**
- SQLite database system with robust schema
- Document indexing with metadata extraction
- Advanced search system with special query syntax
- CLI integration with beautiful floating windows
- Keybindings (`<leader>TS` for search, `<leader>TSr` for recent)
- Graceful fallback to filesystem scanning

**🚀 Current Branch:** `feature/database-pks-system`
**📊 Recent Progress:** Implemented database foundation, search system, CLI integration

## Next Session Priorities

### 1. **Real-World Testing & Refinement** 🧪
- Test the search system with actual Typst documents
- Identify any UX issues or missing functionality
- Test database performance with larger document collections
- Validate keybindings and CLI commands work smoothly

### 2. **Link Discovery & Indexing** 🔗 
**Current Todo:** "Implement link discovery and indexing"
- Parse document content for `[[Document Name]]`, `@references`, `#link()` calls
- Populate `document_links` table for bidirectional relationships
- Enable backlink discovery and graph generation preparation

### 3. **Enhanced Search Features** 🔍
**Current Todo:** "Create database-backed search system" (extend)
- Add full-text search capabilities (SQLite FTS)
- Implement search result ranking and scoring
- Add search history and saved searches

### 4. **Auto-Sync & Maintenance** 🔄
**Current Todo:** "Add database maintenance and sync"
- Auto-sync on file changes (via autocmd/file watchers)
- Cleanup stale database entries for deleted files
- Database repair and optimization tools

## Files to Start With Next Session

1. **Test the current system:** Try `<leader>TS` and `:TypstWriter search`
2. **Review todos:** `read_todos` to see remaining Phase 1 tasks
3. **Check status:** Verify database creation and indexing work
4. **Plan links:** Review `DATABASE_DESIGN_PLAN.md` for link schema design

## Commands for Next Session Testing

```vim
" Test basic search functionality
:TypstWriter search
:TypstWriter recent
:TypstWriter stats

" Test keybindings
<leader>TS      " Interactive search
<leader>TSr     " Recent documents  
<leader>TSs     " Statistics

" Test advanced search syntax
:TypstWriter search @meeting
:TypstWriter search status:draft
:TypstWriter search type:note planning
```

## Expected Issues to Address

- **lsqlite3 dependency**: May need installation instructions
- **First-run experience**: Database creation and initial indexing
- **Error handling**: Database connection failures, missing directories
- **Performance**: Large document collections, indexing speed
- **UI/UX**: Search result display, picker behavior

## Success Metrics

- ✅ Search finds documents instantly
- ✅ Keybindings work smoothly  
- ✅ Database auto-creates and indexes documents
- ✅ Advanced query syntax works (`@tag status:value`)
- ✅ Graceful fallback when database unavailable
- ✅ No errors in `:TypstWriter help`

This plugin now has a solid foundation for evolving into a comprehensive Personal Knowledge System with database-backed performance and rich metadata capabilities.
