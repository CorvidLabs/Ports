import SwiftUI

/// Menu bar popup view displaying ports grouped by category.
struct MenuBarView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @State private var hoveredPort: PortInfo.ID?
    @State private var selectedPort: PortInfo?
    @FocusState private var isSearchFocused: Bool

    private let mono = Theme.mono
    private let monoSmall = Theme.monoSmall
    private let monoTiny = Theme.monoTiny
    private let accent = Theme.accent

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView

            if appState.availableUpdate != nil {
                updateBanner
            }

            Divider().opacity(0.3)

            searchField

            Divider().opacity(0.3)

            if appState.isLoading && appState.ports.isEmpty {
                loadingView
            } else if appState.filteredPorts.isEmpty {
                emptyView
            } else {
                portsList
            }

            Divider().opacity(0.3)

            footerView
        }
        .frame(width: 360)
        .background(Color(nsColor: .windowBackgroundColor))
        .background {
            // Hidden buttons for keyboard shortcuts
            VStack {
                Button("Refresh") { Task { await appState.refresh() } }
                    .keyboardShortcut("r", modifiers: .command)
                Button("Search") { isSearchFocused = true }
                    .keyboardShortcut("f", modifiers: .command)
                Button("Clear") { appState.searchText = "" }
                    .keyboardShortcut(.escape, modifiers: [])
            }
            .opacity(0)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("ports")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(accent)

                Text("\(appState.listeningCount) listening")
                    .font(monoSmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: { Task { await appState.refresh() } }) {
                Group {
                    if appState.isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                    }
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .foregroundStyle(accent)
            .disabled(appState.isLoading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundStyle(accent)

            TextField("filter...", text: $appState.searchText)
                .textFieldStyle(.plain)
                .font(mono)
                .focused($isSearchFocused)

            if !appState.searchText.isEmpty {
                Button(action: { appState.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("scanning...")
                .font(mono)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "network.slash")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("no ports found")
                .font(mono)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }

    // MARK: - Ports List

    private var portsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Favorites section
                if !appState.favoritePorts.isEmpty {
                    Section {
                        ForEach(appState.favoritePorts) { port in
                            portRow(port)
                        }
                    } header: {
                        sectionHeader(icon: "star.fill", label: "pinned", color: .yellow)
                    }
                }

                // Grouped by category
                ForEach(appState.groupedPorts, id: \.category) { group in
                    Section {
                        ForEach(group.ports) { port in
                            portRow(port)
                        }
                    } header: {
                        sectionHeader(
                            icon: group.category.icon,
                            label: group.category.label,
                            color: group.category.color
                        )
                    }
                }
            }
        }
        .frame(maxHeight: 380)
    }

    private func sectionHeader(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(color)
            Text(label)
                .font(.system(.caption2, design: .monospaced, weight: .medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
    }

    private func portRow(_ port: PortInfo) -> some View {
        HStack(spacing: 0) {
            // Risk indicator - simple colored dot
            Text("●")
                .font(.system(size: 8))
                .foregroundStyle(port.risk.color)
                .frame(width: 16)
                .help(riskDescription(port))

            // Port number
            Text(String(format: "%5d", port.port))
                .font(.system(.callout, design: .monospaced, weight: .medium))
                .foregroundStyle(accent)

            // Protocol
            Text(port.transport == .tcp ? "tcp" : "udp")
                .font(monoTiny)
                .foregroundStyle(port.transport == .tcp ? .cyan : .orange)
                .frame(width: 28)

            // Process name
            Text(port.processName)
                .font(monoSmall)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Exposure: * = network, 127 = local
            Text(port.exposureLabel)
                .font(.system(.caption, design: .monospaced, weight: .medium))
                .foregroundStyle(port.isLocalOnly ? .green : .orange)
                .frame(width: 28, alignment: .trailing)

            // PID
            Text(String(port.pid))
                .font(monoTiny)
                .foregroundStyle(.tertiary)
                .frame(width: 50, alignment: .trailing)

            // Actions on hover
            HStack(spacing: 6) {
                Button(action: { appState.toggleFavorite(port.port) }) {
                    Image(systemName: appState.isFavorite(port.port) ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundStyle(appState.isFavorite(port.port) ? .yellow : .secondary.opacity(0.5))
                }
                .buttonStyle(.plain)

                Button(action: { Task { await appState.killProcess(port) } }) {
                    Text("×")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .frame(width: 44)
            .opacity(hoveredPort == port.id ? 1 : 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(hoveredPort == port.id ? Color.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hoveredPort = $0 ? port.id : nil }
        .onTapGesture { selectedPort = port }
        .popover(isPresented: Binding(
            get: { selectedPort?.id == port.id },
            set: { if !$0 { selectedPort = nil } }
        ), arrowEdge: .trailing) {
            PortDetailView(
                port: port,
                onKill: {
                    Task {
                        _ = await appState.killProcess(port)
                        selectedPort = nil
                    }
                },
                onForceKill: {
                    Task {
                        _ = await appState.killProcess(port, force: true)
                        selectedPort = nil
                    }
                },
                onToggleFavorite: { appState.toggleFavorite(port.port) },
                isFavorite: appState.isFavorite(port.port)
            )
        }
        .contextMenu {
            Text("\(port.processName) :\(port.port)")
                .font(.system(.caption, design: .monospaced))

            Divider()

            Button("Copy Port") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(String(port.port), forType: .string)
            }

            Button("Copy PID") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(String(port.pid), forType: .string)
            }

            Divider()

            Button(appState.isFavorite(port.port) ? "Unpin" : "Pin") {
                appState.toggleFavorite(port.port)
            }

            Divider()

            Button("Kill", role: .destructive) {
                Task { await appState.killProcess(port) }
            }

            Button("Force Kill", role: .destructive) {
                Task { await appState.killProcess(port, force: true) }
            }
        }
    }

    // MARK: - Update Banner

    private var updateBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.blue)
                .font(.caption)

            VStack(alignment: .leading, spacing: 0) {
                Text("Update available")
                    .font(monoSmall)
                    .foregroundStyle(.primary)
                if let update = appState.availableUpdate {
                    Text("v\(update.version)")
                        .font(monoTiny)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: { Task { await appState.downloadUpdate() } }) {
                Text("download")
                    .font(monoTiny)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)

            Button(action: { appState.dismissUpdate() }) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 12) {
            // Legend
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Text("127")
                        .foregroundStyle(.green)
                    Text("local")
                        .foregroundStyle(.quaternary)
                }
                HStack(spacing: 2) {
                    Text("*")
                        .foregroundStyle(.orange)
                    Text("network")
                        .foregroundStyle(.quaternary)
                }
            }
            .font(monoTiny)

            Spacer()

            Button(action: { openMainWindow() }) {
                Image(systemName: "macwindow")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Open in Window (⌘0)")

            Button(action: { openSettings() }) {
                Image(systemName: "gear")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings (⌘,)")

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("quit")
                    .font(monoSmall)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "main")
    }

    private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "settings")
    }

    // MARK: - Helpers

    private func riskDescription(_ port: PortInfo) -> String {
        var parts: [String] = []

        switch port.risk {
        case .safe:
            parts.append("Safe: Known process, localhost only")
        case .normal:
            parts.append("Normal: Recognized application")
        case .attention:
            parts.append("Attention: Exposed to network")
        case .unknown:
            parts.append("Unknown: Unrecognized process")
        }

        if port.isExposed {
            parts.append("⚠ Accessible from network")
        }

        if port.isPrivileged {
            parts.append("Privileged port (< 1024)")
        }

        return parts.joined(separator: "\n")
    }
}
