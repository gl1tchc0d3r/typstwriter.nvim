# REWRITE.md - Metadata-Driven Architecture

> **Goal**: Reimplement typstwriter.nvim using Typst's native `#metadata()` and `typst query` for a cleaner, more maintainable codebase.

## 🎯 Core Philosophy

**Before**: Complex regex parsing, manual metadata extraction, fragile string manipulation  
**After**: Native Typst metadata system, `typst query` JSON output, official introspection API

## 🏗️ Architecture Overview

### **New Metadata-First Approach**
```
#metadata((
  type: "meeting",
  title: "Sprint Planning", 
  status: "draft",
  tags: ("sprint", "planning"),
  participants: ("Alice", "Bob")
)) 

↓ (typst query --format json file.typ metadata)

{
  "func": "metadata",
  "value": {
    "type": "meeting",
    "title": "Sprint Planning",
    "status": "draft", 
    "tags": ["sprint", "planning"],
    "participants": ["Alice", "Bob"]
  }
}
```

### **Template Structure**
```typst
// 1. Metadata block (single source of truth)
#metadata((
  type: "document_type",
  title: "Document Title",
  status: "draft",
  tags: ("tag1", "tag2"),
  // ... other fields
))

// 2. Dynamic content using query
#context {
  let meta = query(metadata).first().value
  
  heading(level: 1)[#meta.type.upper(): #meta.title]
  [*Status:* #upper(meta.status)]
  // ... populate from metadata
}

// 3. Document content
Content goes here...
```

## 📁 New Module Structure

### **Core Modules** (Clean Rewrite)
```
lua/typstwriter/
├── metadata.lua     ✅ DONE - Typst query-based extraction
├── v2_templates.lua 🚧 NEW - Metadata-driven template system  
├── v2_compiler.lua  🚧 NEW - Simplified compilation
├── v2_linking.lua   🚧 NEW - Clean document linking
├── v2_config.lua    🚧 NEW - Streamlined configuration
└── v2_init.lua      🚧 NEW - New plugin entry point
```

### **Command Strategy**
- **New Commands**: `TypstWriterCompile`, `TypstWriterNew`, `TypstWriterBoth`, etc.
- **Keep Legacy**: Existing `TWriterCompile`, `TWriterNew` etc. continue working
- **Clean Switch**: When ready, remove legacy and rename new commands

## 🎨 Template System Rewrite

### **New Template Structure**
```
templates/
├── v2/
│   ├── meeting.typ      # Metadata-driven meeting template
│   ├── note.typ         # Simple note template  
│   ├── project.typ      # Project documentation
│   └── base.typ         # Minimal shared utilities
└── legacy/ (move existing templates here)
```

### **Template Discovery Logic**
```lua
-- v2_templates.lua
function get_template_metadata(filepath)
  local meta = metadata.parse_metadata(filepath)
  return {
    name = basename,
    title = meta.title or meta.type or basename,
    type = meta.type or "document",
    description = meta.description or (meta.title .. " template"),
    metadata = meta
  }
end
```

## 🔧 Implementation Steps

### **Phase 1: Core Infrastructure** 
- [x] ✅ `metadata.lua` - Typst query-based extraction
- [x] ✅ `v2_config.lua` - Clean configuration system
- [x] ✅ `v2_utils.lua` - Simplified utilities

### **Phase 2: Template System**
- [x] ✅ `v2_templates.lua` - Metadata-driven template discovery
- [x] ✅ `templates/v2/meeting.typ` - Convert meeting template
- [x] ✅ `templates/v2/note.typ` - Simple note template
- [ ] 🚧 `templates/v2/base.typ` - Minimal base template (if needed)

### **Phase 3: Document Operations**
- [x] ✅ `v2_compiler.lua` - Clean compilation workflow
- [ ] 🚧 `v2_linking.lua` - Metadata-based document linking (next)
- [x] ✅ Commands: `TypstWriterCompile`, `TypstWriterNew`, etc.

### **Phase 4: Integration**
- [x] ✅ `v2_init.lua` - New plugin entry point
- [x] ✅ Test new workflow end-to-end
- [x] ✅ Main plugin integration (parallel system)
- [ ] 🚧 Update integration tests for CI

### **Phase 5: Legacy Cleanup** 
- [ ] 🚧 Remove old modules
- [ ] 🚧 Rename v2 commands to primary names
- [ ] 🚧 Update documentation

## 📝 Template Metadata Schema

### **Standard Fields**
```typst
#metadata((
  // Required
  type: "meeting|note|project|article|report",
  title: "Document Title",
  
  // Optional but recommended  
  status: "draft|review|final|archived",
  date: "YYYY-MM-DD", 
  tags: ("tag1", "tag2", "tag3"),
  
  // Type-specific fields
  // Meeting
  participants: ("Alice", "Bob"),
  duration: "60min",
  
  // Project  
  priority: "high|medium|low",
  deadline: "YYYY-MM-DD",
  
  // Note
  category: "idea|reference|todo",
  
  // Custom fields allowed
  any_field: "any_value",
))
```

### **Validation Rules**
1. `type` and `title` are required
2. `status` defaults to "draft"  
3. `date` defaults to today
4. `tags` must be array (even if empty)
5. Arrays use parentheses: `("item1", "item2")`
6. Strings use quotes: `"string_value"`

## 🧪 Testing Strategy

### **New Test Structure**
```
spec/
├── v2_integration_spec.lua  # New integration tests
├── v2_metadata_spec.lua     # Metadata extraction tests
├── v2_templates_spec.lua    # Template system tests
└── legacy/                  # Move old tests here
```

### **Test Focus Areas**
1. **Metadata Extraction**: `typst query` reliability
2. **Template Discovery**: Metadata-based template info
3. **Document Creation**: New workflow validation
4. **Compilation**: Simplified compiler
5. **Integration**: Full workflow testing

## 🔄 Migration Workflow

### **Development Process**
1. **Parallel Development** - Build v2 alongside legacy
2. **New Commands** - `TypstWriter*` prefix for new functionality  
3. **Template Namespacing** - `v2/` directory for new templates
4. **Progressive Testing** - Validate each component
5. **Clean Switchover** - Remove legacy when ready

### **User Experience During Migration**
- ✅ **Existing users**: Legacy commands continue working
- ✅ **New users**: Can start with v2 commands immediately  
- ✅ **Migration**: Users can gradually adopt new templates
- ✅ **No Breaking Changes**: Until final cutover

## 💭 Design Decisions

### **What We're Keeping**
- ✅ **Core concept**: Template-based document creation
- ✅ **Compilation workflow**: Typst → PDF pipeline
- ✅ **Key mappings**: Similar user experience
- ✅ **Configuration**: Directory settings, preferences

### **What We're Simplifying** 
- 🔄 **Metadata parsing**: Complex regex → `typst query`
- 🔄 **Template styling**: 300+ line base → Minimal base
- 🔄 **Document linking**: Regex parsing → Metadata-driven
- 🔄 **Configuration**: Remove unused complexity

### **What We're Removing**
- ❌ **Complex base.typ**: Too much styling, hard to maintain
- ❌ **Regex parsing**: Fragile and error-prone
- ❌ **Manual metadata extraction**: Let Typst handle it
- ❌ **Duplicate data**: Single source of truth only

## 🎁 Expected Benefits

### **For Users**
- 📝 **Cleaner templates** with less duplication
- 🚀 **More reliable** metadata handling  
- 🔍 **Better search** based on structured metadata
- 📊 **Richer document info** from native Typst features

### **For Developers**
- 🧹 **Cleaner codebase** with less complexity
- 🔧 **Easier maintenance** using official Typst APIs
- 🧪 **Better testing** with reliable data extraction
- 📈 **Future-proof** design following Typst patterns

## 🚦 Current Status

**Active Development**: Building v2 modules alongside legacy system  
**Legacy Status**: Fully functional, no disruption to existing users  
**Migration Progress**: Core metadata system complete ✅

## 🎯 Success Criteria

1. **Functionality Parity**: All current features work with new system
2. **Cleaner Code**: Reduced complexity, better maintainability  
3. **Better UX**: Faster, more reliable metadata handling
4. **Extensibility**: Easy to add new template types and metadata fields
5. **Zero Downtime**: Seamless migration for existing users

---

**Remember**: This rewrite is about **simplification** and **leveraging Typst's native capabilities**. When in doubt, ask "How would Typst want us to do this?" and use official APIs over custom parsing.
