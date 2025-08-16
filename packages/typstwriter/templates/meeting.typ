// Meeting template functions for typstwriter package
#import "../core/base.typ": base, colors

// Meeting template function - creates a complete meeting document template
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
      date: if type(meta.date) == datetime { meta.date } else { datetime.today() },
      doc_type: "meeting",
      status: meta.status,
      tags: meta.tags,
      properties: (
        ("Duration", meta.at("duration", default: "60min")),
        ("Location", meta.at("location", default: "TBD")),
        ("Participants", if meta.participants.len() > 0 { meta.participants.join(", ") } else { "TBD" }),
      )
    )
    
    doc
  }
}

// Meeting-specific header function
#let meeting-header(metadata, style: "default") = {
  // Meeting-specific header with icon and formatting
  heading(level: 1)[📋 Meeting: #metadata.title]
  
  // Additional meeting-specific metadata display
  [*Date:* #metadata.date \
  *Status:* #upper(metadata.status) \
  *Duration:* #metadata.duration]
  
  if metadata.location != "" {
    [\ *Location:* #metadata.location]
  }
  
  if metadata.participants.len() > 0 {
    [\ *Participants:* #metadata.participants.join(", ")]
  }
  
  if metadata.tags.len() > 0 {
    [\ *Tags:* #metadata.tags.join(", ")]
  }
}
