// Main library entry point for typstwriter package
// Re-exports commonly used functions for convenience

// Core functionality
#import "core/base.typ": base, colors, status_badge, tag_badge

// Universal PKM template function
#import "templates/pkm.typ": pkm-template

// Convenience aliases for common document types (backward compatibility)
#let meeting-template = pkm-template
#let note-template = pkm-template
#let person-template = pkm-template
#let guide-template = pkm-template
#let project-template = pkm-template
#let book-template = pkm-template
#let idea-template = pkm-template
#let decision-template = pkm-template

// Main template functions for easy access
#let meeting(..args) = pkm-template(..args)
#let note(..args) = pkm-template(..args)
#let person(..args) = pkm-template(..args)
#let guide(..args) = pkm-template(..args)
#let project(..args) = pkm-template(..args)
#let book(..args) = pkm-template(..args)
#let idea(..args) = pkm-template(..args)
#let decision(..args) = pkm-template(..args)

// Re-export base functions for direct access
#let document-base = base
