# ROADMAP for typstwriter.nvim

> **Get everything, expect nothing!** This roadmap represents ideas, dreams, and "what if" scenarios. Features may arrive Soon™, never, or "It will be ready tomorrow, come back then." 😉

## Vision

Transform **typstwriter.nvim** from a templating system into a comprehensive Personal Knowledge System that rivals Obsidian but remains entirely terminal-based with superior Typst typesetting and **local AI integration**.

## Core Philosophy

- **Terminal-native**: Everything happens in Neovim, no external GUI dependencies
- **Typst-powered**: Leverage Typst's superior typesetting for beautiful documents
- **Metadata-driven**: Use Status, Tags, Document Type, and Properties as the knowledge graph foundation
- **AI-enhanced**: Local LLM integration for intelligent note assistance
- **Privacy-first**: All AI processing happens locally (Ollama, llamafile, etc.)
- **Interlinked**: Rich bi-directional linking between documents
- **Searchable**: Powerful queries based on metadata, content, and AI understanding
- **Visual**: Generate relationship graphs and insights using Typst syntax

---

## Phase 1: Enhanced Linking System

### 1.1 Link Creation (`TWriterLink`)
```vim
:TWriterLink                    " Interactive link picker
:TWriterLink DocumentName       " Direct link to document
<leader>tl                      " Quick link creation keymap
```

**Features:**
- Fuzzy search through all documents
- Show document metadata in picker (status, tags, type)
- Auto-complete existing document names
- Create new documents if target doesn't exist
- Support both `[[Document Name]]` and custom Typst link syntax

### 1.2 Link Navigation (`TWriterFollow`)
```vim
:TWriterFollow                  " Follow link under cursor
<leader>tf                      " Follow link keymap
gf                              " Override default gf for .typ files
```

**Features:**
- Navigate to linked documents
- History stack for back/forward navigation
- Preview linked document in floating window
- Support for section links `[[Document#Section]]`

### 1.3 Backlink Discovery (`TWriterBacklinks`)
```vim
:TWriterBacklinks               " Show backlinks for current document
:TWriterBacklinks DocumentName  " Show backlinks for specific document
<leader>tb                      " Backlinks keymap
```

**Features:**
- Scan all documents for links to current document
- Show context around each backlink
- Navigate directly to backlinking documents
- Update backlinks in real-time when documents change

---

## Phase 2: Metadata-Driven Search & Discovery

### 2.1 Smart Search (`TWriterSearch`)
```vim
:TWriterSearch                  " Interactive multi-criteria search
:TWriterSearch @frontend        " Search by tag
:TWriterSearch status:todo      " Search by status  
:TWriterSearch type:meeting     " Search by document type
<leader>ts                      " Search keymap
```

**Query Syntax:**
```
@tag1 @tag2           " Documents with both tags
status:in-progress    " Documents with specific status
type:meeting OR type:note     " Documents of certain types
created:2025-01       " Documents created in January 2025
updated:last-week     " Recently updated documents
links-to:ProjectX     " Documents linking to ProjectX
has-backlinks:5+      " Documents with 5+ backlinks
```

### 2.2 Document Browser (`TWriterBrowse`)
```vim
:TWriterBrowse                  " Browse all documents with metadata
:TWriterBrowse @urgent          " Browse documents by criteria
<leader>tB                      " Browser keymap
```

**Features:**
- Tree view organized by document type, status, or tags
- Sortable columns (name, date, status, tag count, link count)
- Bulk operations (change status, add tags, etc.)
- Document previews in side panel

### 2.3 Tag Management (`TWriterTags`)
```vim
:TWriterTags                    " Show all tags with usage counts
:TWriterTags @frontend          " Show documents with specific tag
:TWriterTagRename old new       " Rename tag across all documents
<leader>tt                      " Tag management keymap
```

---

## Phase 3: Visual Relationship Mapping

### 3.1 Graph Generation (`TWriterGraph`)
```vim
:TWriterGraph                   " Generate graph for current document
:TWriterGraph --all             " Generate graph for entire knowledge base
:TWriterGraph @frontend         " Generate graph for documents with tag
<leader>tg                      " Graph keymap
```

**Output:** Generate Typst documents with:
- Network diagrams showing document relationships
- Force-directed layout using Typst's drawing capabilities
- Color-coded nodes by document type/status
- Edge weights based on link frequency
- Interactive elements (clickable nodes in PDF)

### 3.2 Relationship Insights (`TWriterInsights`)
```vim
:TWriterInsights                " Generate insights for current document
:TWriterInsights --weekly       " Weekly knowledge activity report
<leader>ti                      " Insights keymap
```

**Generated Reports:**
- Most connected documents (hubs)
- Orphaned documents (no links)
- Tag co-occurrence patterns
- Document creation trends
- Link density analysis
- Content clustering suggestions

### 3.3 Document Templates with Relationships
Update templates to include:
```typst
#import "typst-templates/base.typ": base

#show: base.with(
  // ... existing properties ...
  related_docs: ("ProjectX", "MeetingNotes2025"),
  outgoing_links: auto,  // Auto-discovered
  incoming_links: auto,  // Auto-discovered backlinks
)

// Auto-generated relationship section
= Related Documents

#generate_relationship_map()
#generate_backlinks_section()
```

---

## Phase 4: AI Integration Layer 🤖

### 4.1 AI Chat Interface (`TWriterChat`)
```vim
:TWriterChat                    " Open AI chat about current document
:TWriterChat What's the main point?  " Direct question
<leader>tc                      " Chat keymap
```

**Features:**
- Chat with local LLM about current document or entire knowledge base
- Floating window or split pane interface
- Context-aware responses using document metadata
- Conversation history per document

### 4.2 AI-Powered Note Creation (`TWriterAINew`)
```vim
:TWriterAINew                   " AI-assisted note creation
:TWriterAINew meeting agenda for project review
<leader>tN                      " AI new document keymap
```

**Workflow:**
1. User provides topic/intent
2. AI suggests template and structure
3. AI generates initial content outline
4. User refines and expands
5. Auto-suggests tags, status, and related documents

### 4.3 AI Document Enhancement (`TWriterAIEnhance`)
```vim
:TWriterAIEnhance               " Enhance current document
:TWriterAIEnhance --summarize   " Generate summary
:TWriterAIEnhance --expand      " Expand sections
:TWriterAIEnhance --tags        " Suggest tags
<leader>te                      " AI enhance keymap
```

**Enhancement Options:**
- **Summarize**: Generate executive summaries
- **Expand**: Add detail to bullet points
- **Structure**: Reorganize content logically
- **Tag Suggestions**: Based on content analysis
- **Link Suggestions**: Find related documents
- **Quality Check**: Grammar, clarity, consistency

### 4.4 AI Search & Discovery (`TWriterAISearch`)
```vim
:TWriterAISearch find documents about React hooks
:TWriterAISearch --semantic similar to current document
<leader>tS                      " AI search keymap
```

**AI-Powered Queries:**
- Semantic search (meaning-based, not just keywords)
- Concept clustering
- Find documents that answer specific questions
- Discover implicit relationships between documents

### 4.5 AI Writing Assistant (`TWriterAIAssist`)
```vim
:TWriterAIAssist                " AI writing suggestions for current line/selection
:TWriterAIAssist --complete     " Complete current thought
:TWriterAIAssist --rewrite      " Rewrite selection
<leader>ta                      " AI assist keymap
```

**Writing Features:**
- Real-time writing suggestions
- Complete unfinished sentences
- Rewrite for clarity/tone
- Generate examples and analogies
- Fix grammar and style

### 4.6 AI Configuration & Models
```vim
:TWriterAIConfig                " Configure AI settings
:TWriterAIModels                " List available local models
:TWriterAIStatus                " Check AI system status
```

**Supported Local LLM Backends:**
- **Ollama** (llama3.1, codellama, mistral, etc.)
- **llamafile** (single executable approach)
- **llama.cpp** server mode
- **LocalAI** for OpenAI-compatible API
- **text-generation-webui** integration

**Configuration Options:**
```lua
require('typstwriter').setup({
  -- ... existing config ...
  
  ai = {
    enabled = true,
    backend = "ollama",  -- ollama, llamafile, llama_cpp, localai
    model = "llama3.1:8b",
    
    -- Ollama settings
    ollama = {
      host = "localhost",
      port = 11434,
      timeout = 30000,
    },
    
    -- llamafile settings  
    llamafile = {
      path = "~/.local/bin/llamafile",
      model_path = "~/.local/models/",
    },
    
    -- Features to enable
    features = {
      chat = true,
      enhance = true,
      search = true,
      assist = true,
      auto_suggestions = false,  -- Real-time suggestions
    },
    
    -- Privacy settings
    privacy = {
      local_only = true,
      no_telemetry = true,
      clear_history_on_exit = false,
    }
  }
})
```

---

## Phase 5: Advanced PKS Features

### 5.1 Daily Notes & Journaling
```vim
:TWriterDaily                   " Open/create today's daily note
:TWriterDaily 2025-01-15        " Open specific date
:TWriterWeekly                  " Open/create this week's note
<leader>td                      " Daily note keymap
```

**AI-Enhanced Daily Notes:**
- AI-generated daily prompts
- Auto-summary of previous day's notes
- Mood and productivity tracking
- Smart scheduling based on note content

### 5.2 Project Management Integration
- Project templates with automatic task tracking
- Status workflows (todo → in-progress → review → done)
- Milestone tracking and progress visualization
- Auto-generated project dashboards
- **AI project insights and recommendations**

### 5.3 Knowledge Maintenance
```vim
:TWriterMaintenance             " Run knowledge base maintenance
:TWriterAIMaintenance           " AI-powered maintenance
```

**AI-Enhanced Maintenance:**
- Intelligent broken link detection
- Content similarity analysis for deduplication
- Auto-suggest document merging opportunities
- Tag consistency enforcement
- Stale content identification

### 5.4 Export & Publishing
```vim
:TWriterPublish ProjectName     " Generate publication-ready document
:TWriterAIPublish              " AI-assisted publishing
:TWriterExport --format html    " Export to different formats
```

**AI-Enhanced Publishing:**
- Auto-generate table of contents
- Create executive summaries
- Suggest publication structure
- Generate bibliographies and references

---

## Technical Implementation Strategy

### 1. AI Integration Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   typstwriter   │───▶│   AI Interface   │───▶│   Local LLM     │
│   (Neovim)      │    │   (Lua/HTTP)     │    │ (Ollama/etc.)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Knowledge DB   │    │  Context Store   │    │   Model Cache   │
│  (Metadata)     │    │ (Conversations)  │    │   (Vectors)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### 2. Context Management
- **Document Context**: Send relevant metadata with AI requests
- **Conversation History**: Maintain chat history per document
- **Knowledge Context**: Include related documents in AI queries
- **Privacy Boundaries**: Never send data outside local environment

### 3. Performance & Privacy
- **Local Processing**: Everything happens on-device
- **Efficient Prompting**: Minimize token usage with smart context
- **Caching**: Cache AI responses for repeated queries  
- **Background Processing**: Non-blocking AI operations

### 4. Incremental AI Features
Start with simple completions and gradually add more sophisticated features:
1. **Text completion** (simplest)
2. **Document summarization**
3. **Tag and link suggestions**
4. **Semantic search**
5. **Full conversational interface**

---

## Inspiration Sources

**From Obsidian.md:**
- Graph view and linking concepts
- Tag system and daily notes
- Plugin ecosystem approach

**From Notion.ai:**
- AI writing assistance
- Smart content suggestions
- Automated metadata

**From Roam Research:**
- Bi-directional links
- Block-level references
- Graph database thinking

**From Logseq:**
- Local-first approach
- Block-based structure
- Privacy focus

**What typstwriter.nvim brings uniquely:**
- **Superior typesetting** with Typst
- **Terminal-native** workflow
- **Local AI** with privacy guarantees
- **Version control friendly** plain text
- **Extensible** through Neovim ecosystem

---

## Command Summary

When complete, typstwriter.nvim will offer:

```vim
" Core templating (existing)
:TWriterNew, :TWriterCompile, :TWriterOpen, :TWriterBoth
:TWriterStatus, :TWriterTemplates

" Linking system
:TWriterLink, :TWriterFollow, :TWriterBacklinks

" Search & discovery  
:TWriterSearch, :TWriterBrowse, :TWriterTags

" Visualization
:TWriterGraph, :TWriterInsights

" AI integration 🤖
:TWriterChat, :TWriterAINew, :TWriterAIEnhance
:TWriterAISearch, :TWriterAIAssist
:TWriterAIConfig, :TWriterAIModels, :TWriterAIStatus

" Advanced features
:TWriterDaily, :TWriterMaintenance, :TWriterPublish
```

This creates a **completely unique niche**: A terminal-native Personal Knowledge System with professional typesetting capabilities and local AI assistance - the perfect tool for privacy-conscious knowledge workers, researchers, and writers.

The AI layer makes it not just a note-taking system, but an **intelligent writing companion** that grows more valuable as your knowledge base expands.
