// Meeting Template v2 - Metadata-driven
// Clean, minimal template using Typst's native metadata system

#metadata((
  type: "meeting",
  title: "Meeting Title",
  date: "2024-01-15", 
  status: "draft",
  tags: ("meeting",),
  participants: (),
  duration: "60min",
  location: "",
))

// Basic document setup
#set document(title: "Meeting Title", date: auto)
#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt)
#set heading(numbering: "1.")

// Document header - populated from metadata
#context {
  let meta = query(metadata).first().value
  
  heading(level: 1)[📋 Meeting: #meta.title]
  
  [*Date:* #meta.date \
  *Status:* #upper(meta.status) \
  *Duration:* #meta.duration]
  
  if meta.location != "" {
    [\ *Location:* #meta.location]
  }
  
  if meta.participants.len() > 0 {
    [\ *Participants:* #meta.participants.join(", ")]
  }
  
  if meta.tags.len() > 0 {
    [\ *Tags:* #meta.tags.join(", ")]
  }
}

== Agenda

// Add agenda items here

== Discussion Points

// Key discussion topics

== Decisions Made

// Record decisions and their rationale

== Action Items

// Tasks assigned with owners and deadlines
// Example:
// - [ ] Task description (Owner: Name, Due: Date)

== Next Steps

// Follow-up actions and next meeting date
