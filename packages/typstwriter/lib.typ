// Main library entry point for typstwriter package
// Re-exports commonly used functions for convenience

// Core functionality
#import "core/base.typ": base, colors, status_badge, tag_badge

// Template functions
#import "templates/meeting.typ": meeting-template, meeting-header
#import "templates/note.typ": note-template, note-header

// Main template functions for easy access
#let meeting(..args) = meeting-template(..args)
#let note(..args) = note-template(..args)

// Re-export base functions for direct access
#let document-base = base
