# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0-alpha] - 2025-01-19

### Added
- Launch at Login support via ServiceManagement
- Keyboard shortcuts (`⌘R` refresh, `⌘F` search, `Esc` clear)
- Port details popover on click
- Tabbed Settings window (General, Favorites, About)
- About view with app info and links
- Settings gear button in footer
- Legend in footer explaining exposure indicators

### Changed
- Simplified exposure labels: `127` (local) and `*` (network)
- Cleaner single-line port rows
- Minimal section headers
- Improved terminal-style aesthetic

### Fixed
- Settings button now properly opens Settings window
- Window-based Settings instead of Settings scene for reliability

## [0.1.0-alpha] - 2025-01-19

### Added
- Initial release
- Menu bar app with port list
- Smart categorization (dev, web, database, gaming, media, comms, macos)
- Risk indicators (safe, normal, attention, unknown)
- Exposure info (local vs network)
- One-click process termination
- Force kill option (SIGKILL)
- Pin favorites feature
- Search and filter
- Auto-update checking from GitHub releases
- DMG installer with Applications shortcut

[Unreleased]: https://github.com/CorvidLabs/Ports/compare/v0.2.0-alpha...HEAD
[0.2.0-alpha]: https://github.com/CorvidLabs/Ports/compare/v0.1.0-alpha...v0.2.0-alpha
[0.1.0-alpha]: https://github.com/CorvidLabs/Ports/releases/tag/v0.1.0-alpha
