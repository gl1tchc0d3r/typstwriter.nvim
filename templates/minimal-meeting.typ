// Minimal Meeting Template - Using #metadata
// This template focuses on clean metadata structure

#metadata((
  type: "meeting",
  title: "Meeting Title",
  date: "2024-01-15",
  status: "draft",
  tags: ("meeting", "project"),
  participants: (),
  duration: "60min",
))

// Basic document setup
#set document(title: "Meeting Title", date: auto)
#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)
#set heading(numbering: "1.")

// Document header - dynamically populated from metadata
#context {
  let meta = query(metadata).first().value
  
  heading(level: 1)[Meeting: #meta.title]
  
  [*Date:* #meta.date \
  *Status:* #upper(meta.status) \
  *Duration:* #meta.duration \
  *Tags:* #meta.tags.join(", ")]
  
  if meta.participants.len() > 0 {
    [*Participants:* #meta.participants.join(", ")]
  }
}

== Agenda

// Meeting content starts here

== Discussion Points

== Action Items

== Next Steps

