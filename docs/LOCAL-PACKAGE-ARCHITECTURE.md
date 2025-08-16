# Local Package Architecture Feature

## Overview

This document outlines the requirements and architecture for creating a local Typst package library for typstwriter.nvim. The goal is to centralize styling, layout, and visual formatting logic into a reusable local package while keeping templates focused on content and metadata.

## Motivation

Currently, templates like `meeting.typ`, `note.typ` contain duplicated styling code for:
- Document layout and typography 
- Basic header formatting
- Metadata display
- Page setup and margins

This leads to:
- Code duplication across templates
- Inconsistent styling
- Difficulty maintaining visual consistency
- Limited advanced layout capabilities

## Goals

### Primary Goals
1. **Centralized Styling**: Create a single source of truth for all visual formatting
2. **Template Simplification**: Reduce templates to pure content + metadata
3. **Advanced Layouts**: Enable sophisticated styling like colored tags, enhanced lists, rich headers
4. **Maintainability**: Changes propagate automatically to all templates
5. **Consistency**: Uniform visual appearance across all document types

### Secondary Goals
1. **Extensibility**: Easy to add new styling functions and components
2. **Performance**: Efficient import and compilation
3. **Modularity**: Import only needed styling functions
4. **Customization**: Allow per-document styling overrides

## Architecture Design

### Package Structure
```
packages/
└── typstwriter/
    ├── typst.toml           # Package manifest
    ├── lib.typ              # Main library entry point
    ├── core/
    │   ├── layout.typ       # Page layout and typography
    │   ├── metadata.typ     # Metadata display functions
    │   └── typography.typ   # Font and text styling
    ├── components/
    │   ├── tags.typ         # Colored tag styling
    │   ├── headers.typ      # Enhanced header styles
    │   ├── lists.typ        # List formatting and indentation
    │   └── links.typ        # Link styling and formatting
    └── themes/
        ├── default.typ      # Default color scheme
        ├── corporate.typ    # Corporate theme
        └── academic.typ     # Academic paper theme
```

### Package Manifest (`typst.toml`)
```toml
[package]
name = "typstwriter"
version = "0.1.0" 
description = "Local styling library for typstwriter.nvim templates"
authors = ["typstwriter contributors"]
compiler = "0.11"

[dependencies]
# No external dependencies initially
```

### Core Library Functions

#### Layout Functions
- `document-setup()`: Basic page, font, and paragraph setup
- `template-layout(type, metadata)`: Template-specific layout logic
- `header-footer(metadata)`: Dynamic headers/footers based on metadata

#### Metadata Display
- `render-metadata(metadata, style)`: Smart metadata rendering
- `metadata-header(metadata)`: Document header with metadata
- `status-badge(status)`: Colored status indicators

#### Advanced Styling Components
- `colored-tags(tags, theme)`: Fancy colored tag layout (like shown image)
- `enhanced-headers(level, content, style)`: Rich header formatting
- `smart-lists(items, style)`: Advanced list formatting with proper indentation
- `styled-links(target, text, style)`: Consistent link formatting

### Template Integration

Templates become minimal and focused:

```typst
#import "../packages/typstwriter/lib.typ": *

#metadata((
  type: "meeting",
  title: "Project Review Meeting",
  date: "2025-01-16",
  status: "draft",
  tags: ("project", "review", "urgent"),
  participants: ("Alice", "Bob", "Charlie"),
))

// Apply template with styling options
#show: meeting-template.with(
  theme: "corporate",
  colored-tags: true,
  enhanced-headers: true
)

// Pure content - no styling concerns
== Agenda
- Review Q4 progress
- Discuss budget allocation

== Discussion Points
// Content here...

== Action Items
// Content here...
```

## Implementation Phases

### Phase 1: Core Infrastructure
- [x] Create feature branch
- [ ] Set up package directory structure
- [ ] Create basic typst.toml manifest
- [ ] Implement core layout functions
- [ ] Test basic template import functionality

### Phase 2: Template Refactoring
- [ ] Analyze existing template commonalities
- [ ] Extract shared styling to library functions
- [ ] Update meeting.typ to use package
- [ ] Update note.typ to use package
- [ ] Verify template functionality

### Phase 3: Advanced Styling Components
- [ ] Implement colored tag system
- [ ] Create enhanced header styles
- [ ] Develop smart list formatting
- [ ] Add link styling functions
- [ ] Test advanced layouts

### Phase 4: Theme System
- [ ] Create theme framework
- [ ] Implement default theme
- [ ] Add corporate theme
- [ ] Add academic theme
- [ ] Test theme switching

### Phase 5: Plugin Integration
- [ ] Update typstwriter.nvim configuration
- [ ] Ensure package path resolution works
- [ ] Test template creation workflow
- [ ] Update documentation

## Benefits

### For Template Authors
- Focus on content structure, not styling
- Automatic consistency across documents
- Access to advanced layout capabilities
- Easy theme switching

### For Plugin Development
- Cleaner template architecture
- Easier to add new document types
- Better separation of concerns
- Foundation for PKS features

### For Future PKS Evolution
- Consistent styling for generated content
- Easy to add AI-enhanced formatting
- Visual graph generation compatibility
- Extensible component system

## Technical Considerations

### Import Performance
- Use selective imports where possible
- Lazy-load heavy styling functions
- Cache compiled styles

### Compatibility
- Maintain backward compatibility during transition
- Support both old and new template styles
- Gradual migration path

### Testing Strategy
- Unit tests for individual functions
- Integration tests with actual templates  
- Visual regression tests for styling
- Performance benchmarks

## Success Metrics

- [ ] All existing templates converted to use package
- [ ] Zero styling code duplication in templates
- [ ] Consistent visual appearance across document types
- [ ] Template creation time reduced
- [ ] New styling features easy to add
- [ ] Plugin functionality unchanged for users

## Future Enhancements

### Advanced Components
- Table styling and formatting
- Code block syntax highlighting
- Mathematical notation formatting
- Image and figure layouts

### Interactive Elements
- Clickable elements in PDF output
- Cross-reference styling
- Bibliography formatting
- Index generation

### Collaboration Features
- Version comparison styling
- Comment and review formatting
- Collaborative editing indicators

## Conclusion

This local package architecture will transform typstwriter.nvim from a template system into a comprehensive document styling platform, laying the groundwork for the future Personal Knowledge System while maintaining the metadata-driven philosophy that makes the plugin unique.
