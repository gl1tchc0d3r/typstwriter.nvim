# Database-Backed PKS Implementation Plan

## Context & Vision

**Date**: 2025-08-17  
**Session Summary**: Designed a comprehensive database system for typstwriter.nvim that stores documents with rich semantic metadata per chunk, preparing for AI integration while providing immediate search and linking benefits.

## Key Decisions Made

### Database Choice: SQLite ✅
- **Why**: Perfect for embedded use, excellent Lua bindings, handles our dataset size efficiently
- **Not DuckDB**: Overkill for our OLTP workload, less Lua integration, designed for analytics

### Schema Design Philosophy
- **Full content storage**: Complete document text + chunked content
- **Rich semantic metadata**: Per-chunk topics, entities, keywords, sentiment
- **AI-ready from day one**: Proper chunking for token efficiency
- **Progressive enhancement**: Start minimal, add AI features later

## Database Schema (Final Design)

```sql
-- Documents table (document-level metadata)
CREATE TABLE documents (
  id INTEGER PRIMARY KEY,
  filepath TEXT UNIQUE NOT NULL,
  title TEXT,
  type TEXT,
  status TEXT,
  date TEXT,
  modified_time INTEGER,
  content_hash TEXT,
  content_preview TEXT,      -- 2000 chars for search
  full_content TEXT,         -- Complete content
  summary TEXT,              -- AI-generated document summary (Phase 4)
  topics TEXT,               -- JSON array: ["AI", "databases", "PKS"]
  entities TEXT              -- JSON array: ["SQLite", "DuckDB", "Neovim"]
);

-- Chunks table with rich semantic context
CREATE TABLE document_chunks (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  chunk_index INTEGER,
  content TEXT,
  word_count INTEGER,
  chunk_type TEXT,           -- 'section', 'paragraph', 'code_block', 'list'
  
  -- Semantic context per chunk
  summary TEXT,              -- "This chunk discusses database schema design"
  topics TEXT,               -- JSON: ["database", "schema", "SQLite"] 
  entities TEXT,             -- JSON: ["SQLite", "PRIMARY KEY", "FOREIGN KEY"]
  keywords TEXT,             -- JSON: ["indexing", "performance", "queries"]
  sentiment TEXT,            -- "neutral", "positive", "problem", "solution"
  
  -- Structural context
  heading TEXT,              -- Section heading this chunk belongs to
  heading_level INTEGER,     -- 1=main section, 2=subsection, etc.
  
  -- AI context (Phase 4)
  embedding BLOB,            -- Vector embedding for semantic search
  
  FOREIGN KEY (document_id) REFERENCES documents(id)
);

-- Flexible chunk tagging system
CREATE TABLE chunk_tags (
  id INTEGER PRIMARY KEY,
  chunk_id INTEGER,
  tag TEXT,
  confidence REAL DEFAULT 1.0,   -- AI confidence or 1.0 for manual
  tag_type TEXT,                 -- 'topic', 'entity', 'keyword', 'manual'
  FOREIGN KEY (chunk_id) REFERENCES document_chunks(id)
);

-- Links with context and chunk reference
CREATE TABLE document_links (
  id INTEGER PRIMARY KEY,
  source_id INTEGER,
  target_id INTEGER,
  link_text TEXT,
  source_chunk_id INTEGER,       -- Which chunk contains the link
  context_before TEXT,           -- 100 chars before link
  context_after TEXT,            -- 100 chars after link
  link_type TEXT,                -- 'reference', 'link', 'mention'
  FOREIGN KEY (source_id) REFERENCES documents(id),
  FOREIGN KEY (target_id) REFERENCES documents(id),
  FOREIGN KEY (source_chunk_id) REFERENCES document_chunks(id)
);

-- Indexes for performance
CREATE INDEX idx_documents_filepath ON documents(filepath);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_modified ON documents(modified_time);
CREATE INDEX idx_documents_content_preview ON documents(content_preview);

CREATE INDEX idx_chunks_document ON document_chunks(document_id);
CREATE INDEX idx_chunks_topics ON document_chunks(topics);
CREATE INDEX idx_chunks_content ON document_chunks(content);

CREATE INDEX idx_tags_chunk ON chunk_tags(chunk_id);
CREATE INDEX idx_tags_tag ON chunk_tags(tag);

CREATE INDEX idx_links_source ON document_links(source_id);
CREATE INDEX idx_links_target ON document_links(target_id);
```

## Implementation Plan (Incremental Steps)

### Phase 1.0: Basic Database Infrastructure (Week 1)
**Goal**: Replace current file scanning with SQLite database

#### Step 1.1: Database Module Foundation
- [ ] Create `lua/typstwriter/database.lua`
- [ ] Add SQLite dependency (lsqlite3)
- [ ] Implement basic connection management
- [ ] Create minimal schema (documents table only)
- [ ] Add schema versioning/migrations

#### Step 1.2: Basic Document Indexing
- [ ] Implement `index_document(filepath)` function
- [ ] Extract metadata using existing `metadata.lua`
- [ ] Store full content + content preview
- [ ] Add file change detection via hash
- [ ] Create `rebuild_index()` function

#### Step 1.3: Replace linking.lua
- [ ] Implement `get_all_documents()` with DB query
- [ ] Replace file scanning in document picker
- [ ] Add basic content search functionality
- [ ] Maintain backward compatibility

**Deliverable**: Working database-backed document discovery

### Phase 1.1: Content Chunking System (Week 2)
**Goal**: Implement intelligent document chunking

#### Step 1.4: Chunking Engine
- [ ] Add `document_chunks` table
- [ ] Implement semantic chunking by Typst headings
- [ ] Handle large sections with paragraph splitting
- [ ] Store chunk metadata (type, heading, word count)

#### Step 1.5: Chunk-Based Search
- [ ] Implement chunk content search
- [ ] Add chunk context retrieval
- [ ] Create chunk navigation functions

**Deliverable**: Documents stored as searchable chunks

### Phase 1.2: Link System Enhancement (Week 3)
**Goal**: Rich linking with chunk context

#### Step 1.6: Link Detection & Storage
- [ ] Add `document_links` table
- [ ] Parse document content for links (`[[]]`, `@ref`, `#link()`)
- [ ] Store link context (before/after text)
- [ ] Reference source chunks for links

#### Step 1.7: Enhanced Link Commands
- [ ] Update `TWriterLink` with chunk context
- [ ] Implement `TWriterBacklinks` with rich context
- [ ] Add `TWriterFollow` with preview
- [ ] Show link context in selection UI

**Deliverable**: Contextual linking system

### Phase 1.3: Semantic Metadata Foundation (Week 4)
**Goal**: Prepare for AI integration without requiring AI

#### Step 1.8: Metadata Structure
- [ ] Add `chunk_tags` table
- [ ] Implement manual topic/entity extraction
- [ ] Add basic keyword extraction (frequency analysis)
- [ ] Store structural context (headings, levels)

#### Step 1.9: Enhanced Search
- [ ] Implement topic-based search
- [ ] Add entity-based filtering
- [ ] Create combined metadata + content search
- [ ] Add search result ranking

**Deliverable**: Rich metadata search without AI dependency

### Phase 2: CLI Integration (Week 5)
**Goal**: Integrate database features into CLI commands

#### Step 2.1: Database Commands
- [ ] `TWriterSearch` with advanced query syntax
- [ ] `TWriterBrowse` with metadata columns
- [ ] `TWriterMaintenance` for DB operations
- [ ] `TWriterStats` for collection insights

#### Step 2.2: Database Maintenance
- [ ] Implement incremental sync
- [ ] Add database repair functions
- [ ] Create backup/restore functionality
- [ ] Add performance monitoring

**Deliverable**: Complete CLI database integration

### Phase 3: Performance Optimization (Week 6)
**Goal**: Optimize for large document collections

#### Step 3.1: Advanced Indexing
- [ ] Add Full-Text Search (FTS5) when needed
- [ ] Optimize query performance
- [ ] Add query result caching
- [ ] Implement lazy loading patterns

#### Step 3.2: Memory Management
- [ ] Optimize large document handling
- [ ] Add connection pooling if needed
- [ ] Implement result streaming for large queries

**Deliverable**: Production-ready performance

### Phase 4: AI Integration (Future)
**Goal**: Add AI-powered features using existing infrastructure

#### Step 4.1: AI Context Extraction
- [ ] Add embedding storage (BLOB column ready)
- [ ] Implement AI-based chunk analysis
- [ ] Add semantic similarity search
- [ ] Create AI-powered tag suggestions

#### Step 4.2: AI-Enhanced Features
- [ ] `TWriterAISearch` with semantic queries
- [ ] `TWriterAISummarize` document summaries
- [ ] `TWriterAILink` intelligent link suggestions
- [ ] `TWriterAIChat` document Q&A

**Deliverable**: Full AI-powered PKS

## File Structure

```
lua/typstwriter/
├── init.lua              # Updated to use database
├── cli.lua               # Updated with new commands
├── config.lua            # Add database config options
├── database.lua          # NEW: Core database operations
├── chunking.lua          # NEW: Document chunking logic
├── indexing.lua          # NEW: Content indexing system
├── search.lua            # NEW: Advanced search functions
├── maintenance.lua       # NEW: Database maintenance
└── ai.lua                # NEW: AI integration (Phase 4)
```

## Key Implementation Notes

### Database Dependencies
- Use `lsqlite3` Lua binding
- Handle database file location in user's notes directory
- Implement proper connection management and error handling

### Chunking Strategy
1. **Primary**: Split by Typst headings (`=`, `==`, `===`)
2. **Secondary**: Split large sections by paragraphs
3. **Preserve context**: Store heading hierarchy and surrounding text
4. **Token awareness**: Keep chunks ~1000-2000 tokens for AI readiness

### Performance Considerations
- Index frequently searched columns
- Use prepared statements for repeated queries
- Implement pagination for large result sets
- Cache expensive operations

### AI Integration Preparation
- Store content in AI-friendly chunks from day one
- Design schema to accommodate embeddings later
- Plan for token-efficient context assembly
- Prepare for local LLM integration (Ollama)

## Testing Strategy

### Phase 1 Testing
- [ ] Unit tests for database operations
- [ ] Integration tests with existing templates
- [ ] Performance tests with large document collections
- [ ] Migration tests for schema changes

### Performance Benchmarks
- [ ] Index 1000 documents benchmark
- [ ] Search query performance
- [ ] Link discovery speed
- [ ] Memory usage with large documents

## Configuration Extensions

Add to `config.lua`:
```lua
database = {
  enabled = true,
  file_location = "notes_dir",  -- or custom path
  auto_index = true,
  chunk_size = 2000,           -- target chunk size in characters
  enable_ai_features = false,  -- Phase 4
  maintenance_interval = 3600, -- auto-sync interval in seconds
}
```

## Migration Strategy

1. **Backward Compatibility**: Keep existing features working
2. **Gradual Migration**: Database features optional initially  
3. **Data Migration**: Migrate existing notes to database
4. **Performance Validation**: Compare old vs new performance

## Success Criteria

### Phase 1 Complete When:
- [ ] All existing linking functionality replaced with database
- [ ] Search performance improved over file scanning
- [ ] Document chunking working correctly
- [ ] Zero data loss during migration
- [ ] All tests passing

### Ready for AI Integration When:
- [ ] Rich semantic metadata stored per chunk
- [ ] Token-efficient context assembly working
- [ ] Schema supports embeddings and AI metadata
- [ ] Performance optimized for large collections

## Future Considerations

### Phase 5 & Beyond:
- Vector database integration for semantic search
- Real-time collaboration features
- Advanced AI agents for content creation
- Integration with external knowledge sources
- Mobile/web interface for knowledge base

---

**Next Session Priorities**:
1. Implement basic database module (Step 1.1)
2. Create minimal schema and migration system
3. Replace file scanning in existing linking code
4. Set up testing framework for database operations

**Key Files to Track Changes**:
- `lua/typstwriter/linking.lua` (to be replaced/updated)
- `lua/typstwriter/config.lua` (database config)
- `spec/integration_spec.lua` (update tests)
