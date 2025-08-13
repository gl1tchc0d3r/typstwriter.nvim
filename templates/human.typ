#import "typst-templates/base.typ": base

// Human profile template for documenting people and their information
// This template helps maintain consistent records of individuals
// Can be linked from other documents for reference
#show: base.with(
  title: "Person Name",
  date: datetime.today(),
  doc_type: "human",
  status: "ACTIVE",
  tags: ("person", "contact"),
  properties: (
    ("Full Name", "First Last"),
    ("Role", "Job Title or Role"),
    ("Organization", "Company or Organization"),
    ("Email", "person@example.com"),
    ("Phone", "+1 (555) 123-4567"),
    ("Superior", [#link("Other Person.abc123.typ")[Person Name]]),
  ),
)

= Overview
Brief description of the person, their background, and why they're relevant to document.

= Professional Information
== Current Role
Current position, responsibilities, and key areas of expertise.

== Background & Experience
Previous roles, career progression, notable achievements.

== Skills & Expertise
- Technical skills
- Domain expertise
- Languages spoken
- Certifications

= Contact & Communication
== Preferred Communication
- Email for formal matters
- Slack/Teams for quick questions
- Phone for urgent issues

== Time Zone & Availability
- Time zone: UTC-X
- Typical working hours: 9 AM - 5 PM
- Best times to reach: Morning/Afternoon

= Collaboration Notes
== Working Style
How they prefer to work, communication style, meeting preferences.

== Projects & Involvement
Current and past projects they're involved with.

== Relationships
Key relationships, team members, collaborators.

= Personal Notes
== Interests & Hobbies
Personal interests that might be relevant for building rapport.

== Meeting History
=== [Date] - Meeting/Interaction Title
Brief notes about interactions, decisions made, action items.

= References & Links
- Internal company profile
- Portfolio or personal website  
- Social media profiles
- Relevant documents or presentations
