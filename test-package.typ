#import "packages/typstwriter/lib.typ": meeting, note

#metadata((
  type: "meeting",
  title: "Package Test Meeting",
  date: "2025-01-16",
  status: "draft",
  tags: ("test", "package", "architecture"),
  participants: ("Developer", "Architect"),
  duration: "30min",
  location: "Local Development",
))

#show: meeting

== Agenda
- Test package import functionality
- Verify template rendering
- Check styling consistency

== Discussion Points
This is a test to verify that our new package architecture works correctly.

=== Code Testing
Here's some inline code `import package` and a code block:

```typst
#import "packages/typstwriter/lib.typ": meeting
#show: meeting
```

=== List Testing
- First item
- Second item with *bold* text
- Third item with _italic_ text

== Action Items
- [x] Create package structure
- [x] Implement basic templates
- [ ] Test advanced components
- [ ] Refactor existing templates

== Conclusion
If this document renders correctly, the basic package infrastructure is working!
