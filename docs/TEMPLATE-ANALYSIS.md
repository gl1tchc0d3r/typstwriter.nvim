# Template Architecture Analysis

## Current State

### Existing Template Structure

The typstwriter.nvim project already has a sophisticated template system with several components:

#### 1. Base Template System (`base.typ`)
A comprehensive foundation template that provides:

**Professional Styling:**
- Color palette with primary, status, and text colors
- Typography with Iosevka NFP/NFM font stack
- Professional link styling with underlines
- Enhanced code blocks with monospace fonts
- Heading hierarchy with proper sizing and colors

**Advanced Components:**
- `status_badge(status)`: Deterministic color system for status indicators
- `tag_badge(tag)`: Consistent coloring for tags using codepoint hashing
- Professional grid layouts for metadata display
- Properties section with structured display

**Layout Features:**
- A4 page setup with proper margins
- Heading numbering (1.1.1 format)
- List formatting with proper indentation
- Block styling for code and content

#### 2. Content Templates
**Meeting Template (`meeting.typ`):**
- Simple document setup duplication
- Basic metadata display using `#context` and `query(metadata)`
- Static content sections (Agenda, Discussion, Action Items)
- Manual metadata formatting

**Note Template (`note.typ`):**
- Similar document setup duplication
- Metadata display similar to meeting template
- Static content sections (Overview, Content, References)

#### 3. Example Template
- Comprehensive showcase of base.typ features
- Demonstrates advanced tag and status usage
- Shows all typography and code styling capabilities

## Analysis: What Can Be Extracted

### 1. **Duplicated Document Setup (HIGH PRIORITY)**
Both `meeting.typ` and `note.typ` contain:
```typst
#set document(title: "...", date: auto)
#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)
#set heading(numbering: "1.")
```

**Extraction Opportunity:** Create a `document-setup()` function in the package.

### 2. **Metadata Display Logic (HIGH PRIORITY)**
Both templates have similar but different metadata rendering:
```typst
#context {
  let meta = query(metadata).first().value
  // Different display logic for each template
}
```

**Extraction Opportunity:** Create template-specific metadata renderers:
- `meeting-header(metadata)`
- `note-header(metadata)`
- `generic-header(metadata)`

### 3. **Template-Specific Styling (MEDIUM PRIORITY)**
Each template has its own emoji and formatting:
- Meeting: `📋 Meeting: #meta.title`
- Note: `📝 #meta.title`

**Extraction Opportunity:** Template-specific styling functions with consistent themes.

### 4. **Content Structure (LOW PRIORITY)**
Static content sections are template-specific and should remain in templates.

## Integration Opportunities

### 1. **Leverage Existing Base System**
The `base.typ` system is already sophisticated and should be:
- Moved into the package structure
- Enhanced with additional components
- Made more modular for selective importing

### 2. **Template Simplification**
Templates should become:
```typst
#import "../packages/typstwriter/lib.typ": meeting-template
#metadata((
  // metadata here
))
#show: meeting-template
// content only
```

### 3. **Enhanced Components**
Build on existing `status_badge` and `tag_badge` to create:
- More tag layout options (like the image example)
- Enhanced status visualizations
- Rich metadata displays

## Migration Strategy

### Phase 1: Package Foundation
1. Move `base.typ` into package structure
2. Create modular imports for specific features
3. Add template-specific functions

### Phase 2: Template Refactoring
1. Update templates to use package imports
2. Remove duplicated setup code
3. Test functionality equivalence

### Phase 3: Enhancement
1. Add advanced styling components
2. Implement theme system
3. Create rich layout options

## Specific Extraction Plan

### Core Functions to Extract:
1. **`document-setup()`** - Standard page/text setup
2. **`meeting-template()`** - Complete meeting document template
3. **`note-template()`** - Complete note document template
4. **`render-metadata(meta, template-type)`** - Smart metadata display
5. **`enhanced-tags(tags, style)`** - Rich tag layouts
6. **`status-display(status, style)`** - Enhanced status badges

### Package Structure:
```
packages/typstwriter/
├── lib.typ                 # Main exports
├── core/
│   ├── base.typ           # Existing base.typ (moved)
│   ├── document.typ       # Document setup functions
│   └── metadata.typ       # Metadata rendering
├── templates/
│   ├── meeting.typ        # Meeting-specific functions
│   ├── note.typ          # Note-specific functions
│   └── generic.typ       # Generic template functions
└── components/
    ├── tags.typ          # Enhanced tag components
    ├── status.typ        # Status display components
    └── layout.typ        # Layout utilities
```

## Benefits of This Approach

### Immediate Benefits:
- Eliminates code duplication between templates
- Leverages existing sophisticated styling
- Maintains backward compatibility
- Easy to test and validate

### Future Benefits:
- Foundation for advanced PKS features
- Easy to add new template types
- Consistent styling across all documents
- Theme system ready for implementation

## Conclusion

The existing system already has excellent foundations with `base.typ`. The extraction should focus on:
1. Moving the base system into package structure
2. Creating template-specific wrapper functions
3. Eliminating setup code duplication
4. Building on existing badge systems for enhanced components

This approach minimizes disruption while maximizing the benefits of the package architecture.
