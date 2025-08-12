// Base template system - compatible with existing templates
// This provides common styles and utilities for all document types

// Professional Color Palette
// Based on GitHub Primer + Tailwind professional grays
#let colors = (
  // Primary colors
  primary: rgb("#0969da"),      // Links, primary actions
  primary-hover: rgb("#218bff"), // Hover states
  
  // Status colors
  success: rgb("#1f883d"),       // Completed, success
  warning: rgb("#d97706"),       // Planned, warnings
  error: rgb("#dc2626"),         // Errors, urgent
  
  // Text hierarchy
  text-primary: rgb("#1f2937"),   // H1, body text
  text-secondary: rgb("#374151"), // H2 headings
  text-tertiary: rgb("#4b5563"),  // H3 headings  
  text-muted: rgb("#6b7280"),     // Metadata, captions
  text-subtle: rgb("#9ca3af"),    // Very subtle text
  
  // Background colors
  bg-subtle: rgb("#f9fafb"),      // Light backgrounds
  border-subtle: rgb("#e5e7eb"),  // Light borders
)

// Smart status coloring system - handles unlimited statuses with consistent colors
// Each status gets a deterministic color based on its name (same status = same color)
#let status_badge(status) = {
  // Advanced deterministic hash using codepoints for better character coverage
  // This handles any Unicode character (letters, numbers, symbols, etc.)
  let hash = status.len() * 3  // Base hash on length
  
  // Add codepoint-based hash for robust character handling
  if status.len() > 0 {
    // Get first character's codepoints for numeric hash
    let codepoints = status.codepoints()
    if codepoints.len() > 0 {
      // Use first codepoint as hash component - works for any character
      let first_codepoint = codepoints.first()
      // Convert codepoint to a manageable number using modulo
      hash += calc.rem(str.to-unicode(first_codepoint), 100)
    }
  }
  // Professional status color palette - focused on status semantics
  let status_colors = (
    colors.warning,      // Amber - for planning, pending
    colors.primary,      // Blue - for in-progress, active
    colors.success,      // Green - for completed, done
    colors.error,        // Red - for blocked, cancelled
    rgb("#8b5cf6"),     // Purple - for review, waiting
    rgb("#06b6d4"),     // Cyan - for testing, validation  
    rgb("#f97316"),     // Orange - for urgent, priority
    rgb("#84cc16"),     // Lime - for approved, ready
    rgb("#6366f1"),     // Indigo - for draft, initial
    rgb("#ec4899"),     // Pink - for on-hold, paused
    rgb("#10b981"),     // Emerald - for verified, confirmed
    colors.text-muted,   // Gray - for archived, inactive
  )
  
  // Select color based on hash - same status always gets same color
  let color = status_colors.at(calc.rem(hash, status_colors.len()))
  
  box(
    fill: color.lighten(85%),
    stroke: 1pt + color,
    inset: (x: 8pt, y: 4pt),
    radius: 4pt,
    text(size: 9pt, weight: "bold", fill: color, upper(status))
  )
}

// Smart tag coloring system - handles unlimited tags with consistent colors
// Each tag gets a deterministic color based on its name (same tag = same color)
#let tag_badge(tag) = {
  // Advanced deterministic hash using codepoints for better character coverage
  // This handles any Unicode character (letters, numbers, symbols, etc.)
  let hash = tag.len() * 7  // Base hash on length
  
  // Add codepoint-based hash for robust character handling
  if tag.len() > 0 {
    // Get first character's codepoints for numeric hash
    let codepoints = tag.codepoints()
    if codepoints.len() > 0 {
      // Use first codepoint as hash component - works for any character
      let first_codepoint = codepoints.first()
      // Convert codepoint to a manageable number using modulo
      hash += calc.rem(str.to-unicode(first_codepoint), 100)
    }
  }
  
  // Professional tag color palette - carefully chosen for readability and distinction
  let tag_colors = (
    colors.primary,      // Blue - #0969da
    colors.success,      // Green - #1f883d  
    colors.warning,      // Amber - #d97706
    rgb("#8b5cf6"),     // Purple - professional purple
    rgb("#ec4899"),     // Pink - professional pink
    rgb("#06b6d4"),     // Cyan - professional cyan
    rgb("#84cc16"),     // Lime - professional lime
    rgb("#f59e0b"),     // Yellow - professional yellow
    rgb("#6366f1"),     // Indigo - professional indigo
    rgb("#10b981"),     // Emerald - professional emerald
    rgb("#f97316"),     // Orange - professional orange
    rgb("#e11d48"),     // Rose - professional rose
  )
  
  // Select color based on hash - same tag always gets same color
  let color = tag_colors.at(calc.rem(hash, tag_colors.len()))
  
  box(
    fill: color.lighten(85%),
    stroke: 1pt + color,
    inset: (x: 6pt, y: 2pt),
    radius: 3pt,
    text(size: 8pt, fill: color, tag)
  )
}

#let base(
  title: none,
  date: none,
  doc_type: "document",
  status: "draft",
  tags: (),
  properties: (),
  body
) = {
  // Document metadata
  set document(
    title: title,
    author: "Your Name" // You can customize this
  )
  
  // Page layout
  set page(
    paper: "a4",
    margin: (top: 1.5cm, bottom: 2cm, left: 2cm, right: 2cm),
  )
  
  // Typography - Professional mixed fonts
  set text(
    font: ("Iosevka NFP", "DejaVu Sans", "FreeSans"),
    size: 10pt,
    lang: "en"
  )
  
  // Enable heading numbering
  set heading(numbering: "1.1.1")
  
  // Professional link styling
  show link: it => {
    set text(fill: colors.primary)
    underline(offset: 2pt, stroke: 0.7pt + colors.primary.lighten(50%), it)
  }
  
  // Enhanced code styling with monospace fonts
  show raw.where(block: true): it => {
    set block(
      fill: colors.bg-subtle,
      stroke: (left: 3pt + colors.primary.lighten(60%)),
      inset: (left: 1em, rest: 0.8em),
      radius: 4pt
    )
    set text(font: ("Iosevka NFM", "Hack Nerd Font Mono", "DejaVu Sans Mono"))
    it
  }
  
  show raw.where(block: false): it => {
    box(
      fill: colors.bg-subtle,
      inset: (x: 0.3em, y: 0.1em),
      radius: 2pt,
      text(font: ("Iosevka NFM", "Hack Nerd Font Mono", "DejaVu Sans Mono"), fill: colors.text-secondary, it)
    )
  }
  
  // Headings styling with professional color hierarchy - optimized spacing
  show heading.where(level: 1): it => {
    set text(size: 12pt, weight: "bold", fill: colors.text-primary)
    set block(above: 1.2em, below: 0.8em, breakable: false)
    block(width: 100%, [
      #counter(heading).display(it.numbering) #h(0.4em) #it.body
    ])
  }
  
  show heading.where(level: 2): it => {
    set text(size: 11pt, weight: "semibold", fill: colors.text-secondary) 
    set block(above: 1em, below: 0.6em, breakable: false)
    block(width: 100%, [
      #counter(heading).display(it.numbering) #h(0.4em) #it.body
    ])
  }
  
  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "medium", fill: colors.text-tertiary)
    set block(above: 0.8em, below: 0.5em, breakable: false)
    block(width: 100%, [
      #counter(heading).display(it.numbering) #h(0.4em) #it.body
    ])
  }
  
  // Enhanced lists - tighter spacing
  set list(indent: 1em, spacing: 0.3em)
  set enum(indent: 1em, spacing: 0.3em)
  
  // Header with title and date
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [
      #if title != none {
        text(size: 16pt, weight: "bold", fill: colors.text-primary, title)
      }
    ],
    [
      #if date != none {
        text(size: 9pt, fill: colors.text-muted, date.display("[month repr:short] [day], [year]"))
      }
    ]
  )
  
  v(1em)
  
  // Status and tags section
  // Ensure tags is always treated as an array
  let tag_array = if type(tags) == array { tags } else if type(tags) == str { (tags,) } else { () }
  
  if status != none or tag_array.len() > 0 {
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      row-gutter: 0.5em,
      align: (left + horizon, left + horizon),
      [
        *Status:*
      ],
      [
        #status_badge(status)
      ],
      [
        *Tags:*
      ],
      [
        #tag_array.map(tag => tag_badge(tag)).join(h(0.3em))
      ]
    )
    v(1.5em)
  }
  
  // Properties section in a gray box
  if properties.len() > 0 {
    block(
      fill: colors.bg-subtle,
      stroke: 1pt + colors.border-subtle,
      inset: 1em,
      radius: 6pt,
      width: 100%,
      [
        #set text(size: 9pt)
        #text(weight: "bold", size: 9pt, fill: colors.text-secondary)[PROPERTIES]
        #v(0.4em)
        #set text(font: ("Iosevka NFM", "DejaVu Sans Mono", "FreeMono")) // Monospace for alignment
        #grid(
          columns: (auto, 1fr),
          row-gutter: 0.4em,
          column-gutter: 2em,
          ..properties.map(((key, value)) => {
            (
              text(weight: "semibold", fill: colors.text-tertiary)[#key:],
              text(fill: colors.text-primary)[#value]
            )
          }).flatten()
        )
      ]
    )
    v(1.5em)
  }
  
  // Body content with professional styling - optimized density
  set par(leading: 0.55em, justify: false)
  set block(spacing: 0.8em)
  set text(fill: colors.text-primary)
  
  body
}
