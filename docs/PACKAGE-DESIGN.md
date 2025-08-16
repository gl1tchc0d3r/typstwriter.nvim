# Local Package Design Specification

## Overview

This document details the design for the typstwriter local package, building on the existing sophisticated base template system while creating a modular, extensible architecture.

## Package Structure

```
packages/
└── typstwriter/
    ├── typst.toml              # Package manifest
    ├── lib.typ                 # Main library entry point
    ├── core/
    │   ├── base.typ           # Enhanced version of existing base.typ
    │   ├── document.typ       # Document setup utilities
    │   ├── metadata.typ       # Metadata rendering functions
    │   └── colors.typ         # Color system and themes
    ├── templates/
    │   ├── meeting.typ        # Meeting template functions
    │   ├── note.typ           # Note template functions
    │   ├── project.typ        # Project template functions
    │   └── generic.typ        # Generic template utilities
    ├── components/
    │   ├── tags.typ           # Enhanced tag styling (your fancy image!)
    │   ├── status.typ         # Status badge components
    │   ├── headers.typ        # Header styling and numbering
    │   ├── lists.typ          # List formatting and indentation
    │   ├── links.typ          # Link styling and formatting
    │   └── layout.typ         # Layout utilities and grids
    └── themes/
        ├── default.typ        # Default theme (current colors)
        ├── corporate.typ      # Corporate theme
        ├── academic.typ       # Academic paper theme
        └── minimal.typ        # Minimal theme
```

## Package Manifest

### `typst.toml`
```toml
[package]
name = "typstwriter"
version = "0.1.0"
description = "Local styling library for typstwriter.nvim templates"
authors = ["typstwriter contributors"]
compiler = "0.11"
license = "MIT"

[dependencies]
# No external dependencies initially - pure Typst

[tool.typstwriter]
# Future: package-specific configuration
theme = "default"
```

## Core Library Design

### `lib.typ` - Main Entry Point
```typst
// Main library entry point
// Re-exports commonly used functions for convenience

// Core functionality
#import "core/base.typ": base, colors, status_badge, tag_badge
#import "core/document.typ": document-setup, page-setup
#import "core/metadata.typ": render-metadata, metadata-header

// Template functions
#import "templates/meeting.typ": meeting-template, meeting-header
#import "templates/note.typ": note-template, note-header
#import "templates/generic.typ": generic-template

// Enhanced components
#import "components/tags.typ": *
#import "components/status.typ": *
#import "components/layout.typ": *

// Themes
#import "themes/default.typ": default-theme

// Main template functions for easy access
#let meeting(..args) = meeting-template(..args)
#let note(..args) = note-template(..args)
#let document(..args) = generic-template(..args)
```

### Template Function Interface

#### Meeting Template Function
```typst
// templates/meeting.typ
#import "../core/base.typ": base
#import "../core/metadata.typ": render-metadata

#let meeting-template(
  // Styling options
  theme: "default",
  colored-tags: true,
  enhanced-status: true,
  // Template behavior
  auto-sections: true,
  metadata-style: "detailed",
  // Content
  doc
) = {
  context {
    let meta = query(metadata).first().value
    
    show: base.with(
      title: meta.title,
      date: meta.date,
      doc_type: "meeting",
      status: meta.status,
      tags: meta.tags,
      properties: (
        ("Duration", meta.at("duration", default: "60min")),
        ("Location", meta.at("location", default: "TBD")),
        ("Participants", meta.participants.join(", ")),
      )
    )
    
    doc
  }
}

#let meeting-header(metadata, style: "default") = {
  // Meeting-specific header with icon and formatting
  heading(level: 1)[📋 Meeting: #metadata.title]
  // Additional meeting-specific metadata display
}
```

#### Note Template Function
```typst
// templates/note.typ
#import "../core/base.typ": base

#let note-template(
  theme: "default",
  colored-tags: true,
  enhanced-status: true,
  metadata-style: "simple",
  doc
) = {
  context {
    let meta = query(metadata).first().value
    
    show: base.with(
      title: meta.title,
      date: meta.date,
      doc_type: "note", 
      status: meta.status,
      tags: meta.tags,
      properties: (
        ("Category", meta.at("category", default: "general")),
      )
    )
    
    doc
  }
}
```

## Enhanced Components

### Advanced Tag System (`components/tags.typ`)
```typst
// Enhanced tag system with multiple layout options
#import "../core/colors.typ": tag-colors, theme-colors

// Existing tag_badge enhanced
#let tag-badge(tag, style: "default") = {
  // Current implementation enhanced with style parameter
}

// NEW: Fancy colored tag layouts (like your image!)
#let tag-grid(tags, style: "colorful") = {
  let tag-colors = (
    rgb("#FF6B6B"), rgb("#4ECDC4"), rgb("#45B7D1"), rgb("#96CEB4"),
    rgb("#FFEAA7"), rgb("#DDA0DD"), rgb("#98D8C8"), rgb("#F7DC6F")
  )
  
  grid(
    columns: auto,
    column-gutter: 0.5em,
    row-gutter: 0.3em,
    ..tags.enumerate().map(((i, tag)) => {
      let color = tag-colors.at(calc.rem(i, tag-colors.len()))
      box(
        fill: color.lighten(80%),
        stroke: 2pt + color,
        radius: 8pt,
        inset: (x: 10pt, y: 6pt),
        text(
          size: 9pt,
          weight: "bold",
          fill: color.darken(20%),
          upper(tag)
        )
      )
    })
  )
}

// Block-style tags (like your image)
#let tag-blocks(tags, columns: 3) = {
  grid(
    columns: (1fr,) * columns,
    column-gutter: 0.8em,
    row-gutter: 0.6em,
    ..tags.map(tag => {
      let hash = tag.len() * 7
      let colors = (
        rgb("#E3F2FD"), rgb("#F3E5F5"), rgb("#E8F5E8"),
        rgb("#FFF3E0"), rgb("#FCE4EC"), rgb("#E0F2F1")
      )
      let color = colors.at(calc.rem(hash, colors.len()))
      
      block(
        fill: color,
        stroke: 1pt + color.darken(30%),
        radius: 6pt,
        inset: 8pt,
        width: 100%,
        align(center, text(
          size: 8pt,
          weight: "medium",
          fill: color.darken(60%),
          tag
        ))
      )
    })
  )
}

// Pill-style tags
#let tag-pills(tags) = {
  tags.map(tag => 
    box(
      fill: rgb("#F0F9FF"),
      stroke: 1pt + rgb("#0EA5E9"),
      radius: 12pt,
      inset: (x: 8pt, y: 4pt),
      text(size: 8pt, fill: rgb("#0EA5E9"), tag)
    )
  ).join(h(0.4em))
}
```

### Enhanced Status System (`components/status.typ`)
```typst
// Enhanced status displays beyond basic badges
#import "../core/colors.typ": status-colors

// Progress bar status
#let status-progress(status, progress: 0.0) = {
  let color = status-colors.at(status)
  
  stack(
    dir: ttb,
    spacing: 0.3em,
    text(size: 8pt, weight: "bold", fill: color, upper(status)),
    block(
      width: 100pt,
      height: 4pt,
      stroke: 1pt + color.lighten(40%),
      radius: 2pt,
      fill: color.lighten(80%),
      place(
        left + horizon,
        block(
          width: 100pt * progress,
          height: 4pt,
          radius: 2pt,
          fill: color
        )
      )
    )
  )
}

// Status with icon
#let status-icon(status) = {
  let icons = (
    "draft": "📝",
    "in-progress": "⚡",
    "review": "👀",
    "completed": "✅",
    "blocked": "🚫"
  )
  
  let icon = icons.at(status.lower(), default: "📄")
  box(
    inset: (x: 6pt, y: 3pt),
    [#icon #status]
  )
}
```

### Layout Utilities (`components/layout.typ`)
```typst
// Grid layouts for metadata
#let info-grid(items, columns: 2) = {
  grid(
    columns: (auto, 1fr) * columns,
    column-gutter: 1.5em,
    row-gutter: 0.4em,
    ..items.map(((key, value)) => (
      text(weight: "semibold", size: 9pt)[#key:],
      text(size: 9pt)[#value]
    )).flatten()
  )
}

// Sidebar layout
#let sidebar-layout(sidebar-width: 25%, sidebar, main) = {
  grid(
    columns: (sidebar-width, 1fr),
    column-gutter: 2em,
    sidebar,
    main
  )
}

// Card layout
#let card(title: none, body) = {
  block(
    fill: rgb("#FAFBFC"),
    stroke: 1pt + rgb("#E1E4E8"),
    radius: 6pt,
    inset: 1em,
    width: 100%,
    stack(
      dir: ttb,
      spacing: 0.8em,
      if title != none {
        text(weight: "bold", size: 10pt, title)
      },
      body
    )
  )
}
```

## Theme System

### Theme Interface
```typst
// themes/default.typ
#let default-theme = (
  colors: (
    primary: rgb("#0969da"),
    success: rgb("#1f883d"),
    warning: rgb("#d97706"),
    // ... existing color system
  ),
  typography: (
    main-font: ("Iosevka NFP", "DejaVu Sans", "FreeSans"),
    mono-font: ("Iosevka NFM", "Hack Nerd Font Mono", "DejaVu Sans Mono"),
    sizes: (
      h1: 16pt,
      h2: 14pt,
      body: 10pt,
    )
  ),
  spacing: (
    section: 1.5em,
    paragraph: 0.8em,
  ),
  components: (
    tag-style: "badge",
    status-style: "badge",
    metadata-style: "grid"
  )
)
```

## Migration Strategy

### Phase 1: Core Infrastructure
1. Create package directory structure
2. Move `base.typ` to `core/base.typ` with enhancements
3. Create basic template functions
4. Test with existing templates

### Phase 2: Template Updates
Templates become minimal:
```typst
#import "../packages/typstwriter/lib.typ": meeting

#metadata((
  type: "meeting",
  title: "Project Review",
  // ... metadata
))

#show: meeting

== Agenda
// Pure content only
```

### Phase 3: Enhanced Components
1. Add advanced tag layouts
2. Implement enhanced status displays
3. Create layout utilities
4. Add theme system

## Benefits

### Immediate:
- ✅ Eliminates duplicate code
- ✅ Leverages existing sophisticated styling
- ✅ Backward compatible
- ✅ Easy testing and validation

### Future:
- 🚀 Foundation for PKS features
- 🎨 Rich styling components
- 🎯 Consistent theming
- 🔧 Easy extensibility

## Implementation Notes

### Import Strategy
```typst
// Minimal imports for basic usage
#import "../packages/typstwriter/lib.typ": meeting, note

// Full imports for advanced features  
#import "../packages/typstwriter/components/tags.typ": tag-grid, tag-blocks
#import "../packages/typstwriter/components/layout.typ": card, sidebar-layout
```

### Testing Approach
1. Create test templates using package functions
2. Compare output with existing templates
3. Validate styling consistency
4. Test advanced components

This design builds on your existing excellent foundation while enabling the sophisticated layouts you want, including the fancy colored tags from your example image!
