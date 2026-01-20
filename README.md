# Ports

A lightweight macOS menu bar app for viewing and managing open network ports.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue?style=flat-square)](https://www.apple.com/macos/)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/CorvidLabs/Ports?style=flat-square&include_prereleases)](https://github.com/CorvidLabs/Ports/releases)

## Features

- **Menu bar app** - Always accessible from the system tray
- **Smart categorization** - Ports grouped by type (dev, web, database, gaming, media, comms)
- **Risk indicators** - Visual safety assessment for each port
- **Exposure info** - See if ports are local-only (`127`) or network-exposed (`*`)
- **One-click kill** - Terminate processes directly from the menu
- **Pin favorites** - Quick access to important ports
- **Search & filter** - Find ports by name or number
- **Launch at login** - Start automatically with your Mac
- **Keyboard shortcuts** - Quick actions without clicking

## Installation

### Download

1. Download the latest `.dmg` from [Releases](https://github.com/CorvidLabs/Ports/releases)
2. Open the DMG and drag **Ports** to **Applications**
3. Launch Ports from Applications
4. Look for the network icon in your menu bar

> **Note:** If you see "App is damaged" on unsigned releases, run:
> ```bash
> xattr -cr /Applications/Ports.app
> ```

### Build from Source

```bash
git clone https://github.com/CorvidLabs/Ports.git
cd Ports
swift build && swift run PortViewer
```

## Usage

1. Click the network icon in the menu bar
2. View open ports grouped by category
3. Click any port row to see details
4. Hover to reveal kill/pin actions
5. Right-click for more options

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘R` | Refresh port list |
| `⌘F` | Focus search field |
| `Esc` | Clear search |

### Understanding the Display

```
● 3000 tcp bun       * 92960
│   │   │   │        │   │
│   │   │   │        │   └── Process ID
│   │   │   │        └────── Exposure (* = network, 127 = local)
│   │   │   └─────────────── Process name
│   │   └─────────────────── Protocol
│   └─────────────────────── Port number
└─────────────────────────── Risk indicator
```

### Exposure Indicators

| Symbol | Meaning |
|--------|---------|
| `127` (green) | **Local only** - Only accessible from your Mac |
| `*` (orange) | **Network** - Accessible from other devices on your network |

### Risk Levels

| Color | Level | Description |
|-------|-------|-------------|
| Green | Safe | Known process, localhost only |
| Blue | Normal | Recognized application |
| Orange | Attention | Exposed to network |
| Gray | Unknown | Unrecognized process |

### Categories

| Icon | Category | Examples |
|------|----------|----------|
| 🔨 | dev | Node.js, Bun, Vite, webpack |
| 🌐 | web | nginx, Apache, Caddy |
| 🗄️ | database | PostgreSQL, MySQL, Redis, MongoDB |
| 🎮 | gaming | Steam, Discord (gaming features) |
| ▶️ | media | Spotify, Plex, VLC |
| 💬 | comms | Slack, Discord, Zoom |
| 🍎 | macos | System services |

## Development

### Requirements

- macOS 13.0+
- Swift 5.9+
- Xcode Command Line Tools

### Building

```bash
# Debug build and run
swift build && swift run PortViewer

# Release build
swift build -c release

# Create DMG
./scripts/build-release.sh 0.3.0

# Create signed DMG (requires Developer ID)
./scripts/build-release.sh 0.3.0 "Developer ID Application: Name (TEAMID)"
```

### Project Structure

```
Sources/PortViewer/
├── App.swift              # App entry point and state
├── Models/
│   └── PortInfo.swift     # Port data model
├── Services/
│   ├── PortScanner.swift  # lsof parsing
│   ├── ProcessKiller.swift # Process termination
│   ├── UpdateChecker.swift # GitHub release checking
│   └── LaunchAtLogin.swift # Login item management
└── Views/
    ├── MenuBarView.swift  # Main menu bar popup
    ├── PortDetailView.swift # Port detail popover
    ├── SettingsView.swift # Settings window
    └── AboutView.swift    # About tab
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Made with ❤️ by [CorvidLabs](https://github.com/CorvidLabs)
