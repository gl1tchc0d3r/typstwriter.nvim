// Note template functions for typstwriter package
#import "../core/base.typ": base, colors

// Note template function - creates a complete note document template
#let note-template(
  // Styling options
  theme: "default",
  colored-tags: true,
  enhanced-status: true,
  // Template behavior
  metadata-style: "simple",
  // Content
  doc
) = {
  context {
    let meta = query(metadata).first().value
    
    show: base.with(
      title: meta.title,
      date: if type(meta.date) == datetime { meta.date } else { datetime.today() },
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

// Note-specific header function
#let note-header(metadata, style: "default") = {
  // Note-specific header with icon and formatting
  heading(level: 1)[📝 #metadata.title]
  
  // Additional note-specific metadata display
  [*Date:* #metadata.date \
  *Status:* #upper(metadata.status) \
  *Category:* #metadata.category]
  
  if metadata.tags.len() > 0 {
    [\ *Tags:* #metadata.tags.join(", ")]
  }
}
