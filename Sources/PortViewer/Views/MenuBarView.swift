import SwiftUI

/// Menu bar popup view displaying ports grouped by category.
struct MenuBarView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var hoveredPort: PortInfo.ID?
    @State private var selectedPort: PortInfo?
    @FocusState private var isSearchFocused: Bool

    private let mono = Font.system(.body, design: .monospaced)
    private let monoSmall = Font.system(.caption, design: .monospaced)
    private let monoTiny = Font.system(.caption2, design: .monospaced)
    private let accent = Color(red: 0.4, green: 0.9, blue: 0.6)

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
                            color: categoryColor(group.category)
                        )
                    }
                }
            }
        }
        .frame(maxHeight: 380)
    }

    private func sectionHeader(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(label)
                .font(monoSmall)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
    }

    private func portRow(_ port: PortInfo) -> some View {
        HStack(spacing: 6) {
            // Risk indicator
            Image(systemName: port.risk.icon)
                .font(.caption2)
                .foregroundStyle(riskColor(port.risk))
                .frame(width: 14)
                .help(riskDescription(port))

            // Port number
            Text(String(format: "%5d", port.port))
                .font(.system(.callout, design: .monospaced, weight: .semibold))
                .foregroundStyle(accent)

            // Protocol
            Text(port.transport == .tcp ? "tcp" : "udp")
                .font(monoTiny)
                .foregroundStyle(port.transport == .tcp ? .cyan : .orange)
                .frame(width: 24)

            // Process name
            VStack(alignment: .leading, spacing: 0) {
                Text(port.processName)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    // Exposure indicator
                    Image(systemName: port.isLocalOnly ? "lock.fill" : "network")
                        .font(.system(size: 8))
                    Text(port.exposureLabel)
                        .font(monoTiny)

                    Text("·")
                        .foregroundStyle(.quaternary)

                    Text("pid \(port.pid)")
                        .font(monoTiny)
                }
                .foregroundStyle(.tertiary)
            }

            Spacer()

            // Actions on hover
            HStack(spacing: 4) {
                Button(action: { appState.toggleFavorite(port.port) }) {
                    Image(systemName: appState.isFavorite(port.port) ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(appState.isFavorite(port.port) ? .yellow : .secondary)
                }
                .buttonStyle(.plain)

                Button(action: { Task { await appState.killProcess(port) } }) {
                    Text("kill")
                        .font(monoTiny)
                        .foregroundStyle(.red.opacity(0.9))
                }
                .buttonStyle(.plain)
            }
            .opacity(hoveredPort == port.id ? 1 : 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(hoveredPort == port.id ? Color.primary.opacity(0.06) : Color.clear)
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
            Section {
                Label("Port: \(port.port)", systemImage: "number")
                Label("PID: \(port.pid)", systemImage: "memorychip")
                Label("User: \(port.user)", systemImage: "person")
                Label(port.exposureLabel, systemImage: port.isLocalOnly ? "lock.fill" : "network")
            }

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

            Button(appState.isFavorite(port.port) ? "Unpin" : "Pin to Top") {
                appState.toggleFavorite(port.port)
            }

            Divider()

            Button("Kill (SIGTERM)", role: .destructive) {
                Task { await appState.killProcess(port) }
            }

            Button("Force Kill (SIGKILL)", role: .destructive) {
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
        HStack {
            Toggle(isOn: $appState.showOnlyListening) {
                Text("listen only")
                    .font(monoSmall)
            }
            .toggleStyle(.checkbox)
            .controlSize(.small)

            Spacer()

            Button(action: { openSettings() }) {
                Image(systemName: "gear")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("quit")
                    .font(monoSmall)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    // MARK: - Helpers

    private func categoryColor(_ category: PortInfo.Category) -> Color {
        switch category {
        case .dev: return .orange
        case .web: return .blue
        case .database: return .green
        case .media: return .purple
        case .gaming: return .pink
        case .comms: return .cyan
        case .macos: return .gray
        case .other: return .secondary
        }
    }

    private func riskColor(_ risk: PortInfo.Risk) -> Color {
        switch risk {
        case .safe: return .green
        case .normal: return .blue
        case .attention: return .orange
        case .unknown: return .secondary
        }
    }

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
