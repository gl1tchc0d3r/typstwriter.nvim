// Universal PKM template function for all document types
#import "../core/base.typ": base, colors

// Universal PKM template that adapts based on document type
#let pkm-template(
  // Styling options
  theme: "default",
  colored-tags: true,
  enhanced-status: true,
  // Template behavior
  metadata-style: "auto",
  // Content
  doc
) = {
  context {
    let meta = query(metadata).first().value
    let doc_type = meta.at("type", default: "document")
    
    // Define type-specific properties
    let properties = ()
    
    if doc_type == "person" {
      properties = (
        ("Email", meta.at("email", default: "")),
        ("Phone", meta.at("phone", default: "")),
        ("Location", meta.at("location", default: "")),
        ("Organization", meta.at("organization", default: "")),
        ("Last Contact", meta.at("last_contact", default: "")),
      )
    } else if doc_type == "meeting" {
      properties = (
        ("Duration", meta.at("duration", default: "60min")),
        ("Location", meta.at("location", default: "TBD")),
        ("Participants", if meta.at("participants", default: ()).len() > 0 { meta.participants.join(", ") } else { "TBD" }),
      )
    } else if doc_type == "project" {
      properties = (
        ("Priority", meta.at("priority", default: "medium")),
        ("Start Date", meta.at("start_date", default: "")),
        ("Target Date", meta.at("target_date", default: "")),
        ("Team", if meta.at("team", default: ()).len() > 0 { meta.team.join(", ") } else { "Solo" }),
        ("Client", meta.at("client", default: "")),
        ("Budget", meta.at("budget", default: "")),
      )
    } else if doc_type == "book" {
      properties = (
        ("Author", meta.at("author", default: "")),
        ("Genre", meta.at("genre", default: "")),
        ("Pages", str(meta.at("pages", default: 0))),
        ("Current Page", str(meta.at("current_page", default: 0))),
        ("Rating", meta.at("rating", default: 0) > 0 ? str(meta.rating) + "/5" : "Not rated"),
        ("Started", meta.at("started_date", default: "")),
        ("ISBN", meta.at("isbn", default: "")),
      )
    } else if doc_type == "guide" {
      properties = (
        ("Category", meta.at("category", default: "general")),
        ("Difficulty", meta.at("difficulty", default: "beginner")),
        ("Estimated Time", meta.at("estimated_time", default: "")),
        ("Prerequisites", if meta.at("prerequisites", default: ()).len() > 0 { meta.prerequisites.join(", ") } else { "None" }),
      )
    } else if doc_type == "idea" {
      properties = (
        ("Category", meta.at("category", default: "general")),
        ("Maturity", meta.at("maturity", default: "concept")),
        ("Impact", meta.at("impact", default: "medium")),
        ("Effort", meta.at("effort", default: "medium")),
        ("Inspiration", meta.at("inspiration_source", default: "")),
        ("Related Ideas", if meta.at("related_ideas", default: ()).len() > 0 { meta.related_ideas.join(", ") } else { "None" }),
      )
    } else if doc_type == "decision" {
      properties = (
        ("Decision Date", meta.at("decision_date", default: "")),
        ("Impact Level", meta.at("impact_level", default: "medium")),
        ("Reversible", meta.at("reversible", default: true) ? "Yes" : "No"),
        ("Deadline", meta.at("deadline", default: "")),
        ("Stakeholders", if meta.at("stakeholders", default: ()).len() > 0 { meta.stakeholders.join(", ") } else { "TBD" }),
        ("Context", meta.at("context", default: "")),
      )
    } else if doc_type == "note" {
      properties = (
        ("Category", meta.at("category", default: "general")),
        ("Source", meta.at("source", default: "")),
        ("Source URL", meta.at("source_url", default: "")),
      )
    }
    
    // Filter out empty properties
    properties = properties.filter(((key, value)) => value != "")
    
    show: base.with(
      title: meta.title,
      date: if type(meta.date) == datetime { meta.date } else { datetime.today() },
      doc_type: doc_type,
      status: meta.status,
      tags: meta.tags,
      properties: properties
    )
    
    doc
  }
}
