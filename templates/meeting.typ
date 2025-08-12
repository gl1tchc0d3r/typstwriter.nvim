#import "typst-templates/base.typ": base

// Streamlined meeting template with essential properties only
// Customize title, participants, and datetime for your meeting
// DateTime format: YYYY-MM-DD HH:MM (24-hour, easy to parse with scripts)
#show: base.with(
  title: "Meeting Title",
  date: datetime.today(),
  doc_type: "meeting",
  status: "PLANNED",
  tags: ("meeting"),
  properties: (
    ("DateTime", "2025-01-31 14:30"),
    ("Participants", "Name 1, Name 2"),
    ("Location", "Conference Room / Video Call"),
  ),
)

= Agenda
1. Topic 1
2. Topic 2
3. Topic 3

= Discussion Notes
== Topic 1
Discussion details…

== Topic 2
Discussion details…

= Decisions Made
Key decisions made during the meeting…

= Action Items
Current action items (also automatically listed in summary)…

= Next Steps
What happens next…
