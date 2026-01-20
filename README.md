# Ports

A lightweight macOS menu bar app for viewing and managing open network ports.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)

## Features

- **Menu bar app** - Quick access from the system tray
- **Smart categorization** - Ports grouped by type (dev, web, database, gaming, media, comms, macos)
- **Risk indicators** - Visual safety assessment for each port
- **Exposure info** - See if ports are local-only or network-exposed
- **One-click kill** - Terminate processes directly from the menu
- **Pin favorites** - Quick access to important ports
- **Search/filter** - Find ports by name or number

## Installation

### Download (Recommended)

Download the latest DMG from [Releases](../../releases).

**After installing, run this command to allow the app:**
```bash
xattr -cr /Applications/Ports.app
```

Then open Ports from Applications (or right-click → Open).

> The app is not notarized, so macOS quarantines it. The command above removes the quarantine flag.

### Build from Source

Requires macOS 13+ and Swift 5.9+.

```bash
git clone https://github.com/CorvidLabs/Ports.git
cd Ports
swift build -c release
```

The built app will be at `.build/release/PortViewer`.

To create an app bundle:

```bash
# Build release
swift build -c release

# Run directly
.build/release/PortViewer
```

## Usage

1. Click the network icon in the menu bar
2. View open ports grouped by category
3. Hover over a port to see kill/pin actions
4. Right-click for more options (copy, force kill, etc.)

### Categories

| Icon | Category | Description |
|------|----------|-------------|
| 🔨 | dev | Development servers and tools |
| 🌐 | web | Web servers (nginx, apache) |
| 🗄️ | data | Databases (mysql, postgres, redis) |
| 🎮 | gaming | Games and gaming platforms |
| ▶️ | media | Media and streaming |
| 💬 | comms | Communication apps |
|  | macos | Expected system services |

### Risk Levels

| Color | Level | Meaning |
|-------|-------|---------|
| 🟢 | Safe | Known process, localhost only |
| 🔵 | Normal | Recognized application |
| 🟠 | Attention | Exposed to network |
| ⚪ | Unknown | Unrecognized process |

## Development

```bash
# Build debug
swift build

# Run
swift run PortViewer

# Build release
swift build -c release
```

## License

Internal use only - CorvidLabs
