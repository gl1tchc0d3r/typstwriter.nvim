# CLI-Style Command Structure Design

## Overview

This document outlines the design for refactoring typstwriter.nvim commands from individual command names to a CLI-style structure with subcommands, similar to `git`, `docker`, or `kubectl`.

## Current Issues

1. **Command Proliferation**: Too many top-level commands (12+ commands)
2. **Discoverability**: Hard to find related functionality
3. **Scalability**: Adding new features creates more command clutter
4. **Inconsistency**: No clear organizational structure

## Proposed CLI Structure

### Main Command
```vim
:TypstWriter <subcommand> [options] [arguments]
```

### Document Operations
```vim
:TypstWriter new [template_type] [title]     # Create new document
:TypstWriter compile                         # Compile current document
:TypstWriter open                           # Open PDF
:TypstWriter both                           # Compile and open
```

### Template Management
```vim
:TypstWriter templates list                  # List available templates
:TypstWriter templates update               # Update plugin templates
:TypstWriter templates reset <name>         # Reset template to default
:TypstWriter templates install              # Install templates
```

### Package Management
```vim
:TypstWriter package status                 # Check package installation
:TypstWriter package install               # Install package and fonts
:TypstWriter package update                # Update package and fonts
```

### System Operations
```vim
:TypstWriter setup                          # Complete system setup
:TypstWriter status                         # Overall system status
```

### Future PKS Commands
```vim
:TypstWriter search <query>                 # Search documents
:TypstWriter link <target>                  # Create document links
:TypstWriter graph generate                 # Generate knowledge graph
:TypstWriter ai chat                        # AI chat interface
:TypstWriter ai enhance                     # AI content enhancement
```

## Benefits

1. **Organized**: Related commands grouped logically
2. **Scalable**: Easy to add new subcommands
3. **Discoverable**: Tab completion shows available options
4. **Familiar**: Follows CLI conventions users expect
5. **Future-proof**: Perfect foundation for PKS features

## Implementation Plan

### Phase 1: Core CLI Infrastructure
- [ ] Create main `:TypstWriter` command handler
- [ ] Implement subcommand parsing and routing
- [ ] Add tab completion for subcommands
- [ ] Maintain backward compatibility with deprecated commands

### Phase 2: Command Migration
- [ ] Migrate document operations (new, compile, open, both)
- [ ] Migrate template management commands
- [ ] Migrate package management commands
- [ ] Migrate system commands (setup, status)

### Phase 3: Enhanced Features
- [ ] Add help system (`:TypstWriter help`, `:TypstWriter help templates`)
- [ ] Implement command aliases and shortcuts
- [ ] Add verbose/quiet modes for commands
- [ ] Improve error messages and user feedback

### Phase 4: Documentation Update
- [ ] Update README.md with new command structure
- [ ] Create command reference documentation
- [ ] Update keybinding examples
- [ ] Migration guide for existing users

## Technical Implementation

### Command Registration
```lua
-- Single main command with completion
vim.api.nvim_create_user_command('TypstWriter', function(opts)
  require('typstwriter.cli').execute(opts)
end, {
  nargs = '*',
  complete = require('typstwriter.cli').complete,
})
```

### Subcommand Routing
```lua
local commands = {
  new = require('typstwriter.commands.document').new,
  compile = require('typstwriter.commands.document').compile,
  templates = {
    list = require('typstwriter.commands.templates').list,
    update = require('typstwriter.commands.templates').update,
  },
  -- ... more commands
}
```

### Tab Completion
- First level: Main subcommands (new, templates, package, etc.)
- Second level: Sub-subcommands (templates list, package status, etc.)
- Context-aware completion for arguments

## Backward Compatibility

Maintain existing commands as deprecated aliases:
```vim
:TypstWriterNew -> :TypstWriter new
:TypstWriterTemplates -> :TypstWriter templates list
:TypstWriterPackageStatus -> :TypstWriter package status
```

Show deprecation warnings with migration suggestions.

## Success Criteria

- [ ] All existing functionality accessible via new CLI structure
- [ ] Tab completion works for all subcommands
- [ ] Backward compatibility maintained
- [ ] Documentation updated
- [ ] User experience improved (fewer top-level commands)
- [ ] Foundation ready for future PKS features

## Development Log

### Phase 1 Progress
- [x] Design document created
- [x] Branch merged early into staging (GitHub network graph experiment)
- [ ] CLI module structure implementation (in progress)
- [ ] Subcommand parsing and routing
- [ ] Tab completion system
