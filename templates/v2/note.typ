// Note Template v2 - Metadata-driven
// Simple note template for general documentation

#metadata((
  type: "note",
  title: "Note Title",
  date: "2024-01-15",
  status: "draft", 
  tags: ("note",),
  category: "general",
))

// Basic document setup
#set document(title: "Note Title", date: auto)
#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)
#set heading(numbering: "1.")

// Document header - populated from metadata
#context {
  let meta = query(metadata).first().value
  
  heading(level: 1)[📝 #meta.title]
  
  [*Date:* #meta.date \
  *Status:* #upper(meta.status) \
  *Category:* #meta.category]
  
  if meta.tags.len() > 0 {
    [\ *Tags:* #meta.tags.join(", ")]
  }
}

== Overview

// Brief overview or summary

== Content

// Main content goes here

== References

// Links to related documents or external sources
