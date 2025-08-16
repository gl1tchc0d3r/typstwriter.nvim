#import "../packages/typstwriter/core/base.typ": base

#metadata((
  type: "example",
  title: "Example Template", 
  description: "Comprehensive feature showcase template",
  status: "draft",
  tags: ("example", "showcase", "template"),
  category: "documentation",
))

// COMPREHENSIVE EXAMPLE - Showcases all base.typ features
// This demonstrates the full capabilities of the template system:
// - Multiple status types with automatic coloring
// - Diverse tag formats with special characters, numbers, icons and consistent colors
// - Rich property metadata
// - All heading levels, code blocks, lists, links, and formatting
// Use this as a reference for what's possible!
#show: base.with(
  title: "Comprehensive Template Feature Showcase",
  date: datetime.today(),
  doc_type: "example",
  status: "IN-PROGRESS",
  tags: (
    "@frontend", "#typescript", "v1.2", "🚀urgent", "2025-q4", "@team-alpha"
  ),
  properties: (
    ("Version", "1.2.3"),
    ("Author", "Template Developer"),
    ("Project", "Typst Template System"),
    ("Repository", "github.com/user/typst-templates"),
    ("Last Updated", "2025-08-12 12:00"),
    ("Stakeholders", "Dev Team, Design Team, Product"),
    ("Priority", "High"),
    ("Dependencies", "typst >= 0.11.0"),
  ),
)

= Overview
This document demonstrates all the features available in the `base.typ` template system. It showcases typography, code blocks, links, lists, and the automatic coloring system for tags and status badges.

== Key Features Demonstrated
- *Status badges* with automatic consistent coloring
- *Tag system* supporting special characters including symbols, numbers and emojis
- *Professional typography* with proper heading hierarchy
- *Code highlighting* for both inline and block code
- *Link styling* with professional appearance
- *List formatting* with proper spacing

= Typography Showcase

== Level 2 Heading
This is a level 2 heading with medium emphasis and professional coloring.

=== Level 3 Heading
This is a level 3 heading with lighter emphasis, perfect for subsections.

== Text Formatting
Here are examples of different text formatting:
- *Bold text* for emphasis
- _Italic text_ for subtle emphasis
- `inline code` with monospace font
- Regular paragraph text with professional line spacing

= Code Examples

== Inline Code
When referencing variables like `userName` or functions like `getData()`, the inline code styling makes them stand out clearly.

== Code Blocks
Here's a TypeScript example:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

class UserService {
  async getUser(id: number): Promise<User> {
    const response = await fetch(`/api/users/${id}`);
    return response.json();
  }
}
```

And a Python example:

```python
from typing import List, Optional

class DataProcessor:
    def __init__(self, config: dict):
        self.config = config
    
    def process_items(self, items: List[str]) -> List[str]:
        return [item.strip().lower() for item in items]
```

= Lists and Structure

== Unordered Lists
- First item with important information
- Second item with additional details
  - Nested item showing hierarchy
  - Another nested item
- Third item completing the list

== Ordered Lists
1. First step in the process
2. Second step with detailed explanation
3. Third step showing progression
   1. Sub-step for clarity
   2. Another sub-step
4. Final step

== Task Lists
- [x] Completed task
- [x] Another completed item
- [ ] Pending task
- [ ] Future enhancement

= Links and References

The template supports professional link styling:
- External link: #link("https://typst.app/docs/", "Typst Documentation")
- Email: #link("mailto:d\@example.com", "d\@example.com")
- Internal reference: See the Typography Showcase section above

= Advanced Features

== Status System
The template automatically colors status badges based on their content. Each status gets a consistent color across all documents. Examples include:
- PLANNED (planning phase)
- IN-PROGRESS (active work)
- REVIEW (under review)
- COMPLETED (finished)
- BLOCKED (impediments)

== Tag System
Tags support various formats and automatically get consistent colors:
- `\@frontend` - Team or domain tags
- `#typescript` - Technology tags
- `v1.2` - Version tags
- `🚀urgent` - Priority with emojis
- `2025-q4` - Time-based tags
- `\@team-alpha` - Team identification

== Properties
The properties section supports any key-value pairs for metadata, making documents easily parseable by scripts while maintaining readability.

= Conclusion
This template system provides a professional, consistent foundation for all your documentation needs while maintaining flexibility and extensibility.
