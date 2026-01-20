# Contributing to Ports

Thank you for your interest in contributing to Ports! This document provides guidelines and information for contributors.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Ports.git
   cd Ports
   ```
3. Build and run:
   ```bash
   swift build && swift run PortViewer
   ```

## Development Guidelines

### Code Style

We follow the [CorvidLabs Swift Conventions](https://github.com/CorvidLabs):

- **Explicit access control** - Always specify `public`, `internal`, or `private`
- **K&R brace style** - Opening brace on same line
- **No force unwraps** - Never use `!`, `try!`, or `as!`
- **async/await only** - No completion handlers
- **4-space indentation** - No tabs
- **120 character line limit**

### Commit Messages

Use clear, descriptive commit messages:

```
Add: new feature description
Fix: bug description
Update: existing feature changes
Remove: deleted functionality
Refactor: code restructuring
Docs: documentation changes
```

### Pull Request Process

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and ensure:
   - Code builds without warnings
   - No force unwraps or force try
   - Follows existing code patterns

3. Commit your changes with clear messages

4. Push to your fork and create a Pull Request

5. Fill out the PR template with:
   - Summary of changes
   - Testing performed
   - Screenshots (if UI changes)

### PR Template

```markdown
## Summary
- Brief description of changes

## Changes
- List of specific changes made

## Testing
- [ ] Built successfully
- [ ] Tested on macOS 13+
- [ ] UI changes verified

## Screenshots
(If applicable)
```

## Project Structure

```
Sources/PortViewer/
├── App.swift              # App entry, AppState
├── Models/
│   └── PortInfo.swift     # Data model
├── Services/
│   ├── PortScanner.swift  # Port scanning
│   ├── ProcessKiller.swift # Process termination
│   ├── UpdateChecker.swift # Update checking
│   └── LaunchAtLogin.swift # Login item
└── Views/
    ├── MenuBarView.swift  # Main view
    ├── PortDetailView.swift
    ├── SettingsView.swift
    └── AboutView.swift
```

## Adding Features

### New Port Categories

Edit `Sources/PortViewer/Models/PortInfo.swift`:

1. Add to the `Category` enum
2. Update `icon` computed property
3. Update `sortOrder` property
4. Update the category detection in `category` computed property

### New Services

Create a new file in `Sources/PortViewer/Services/`:

1. Use `actor` for shared state
2. Make it `Sendable`
3. Use async/await patterns
4. Add to `AppState` if needed

## Reporting Issues

When reporting issues, please include:

- macOS version
- App version
- Steps to reproduce
- Expected vs actual behavior
- Any error messages

## Questions?

Open an issue with the `question` label or start a discussion.

---

Thank you for contributing!
