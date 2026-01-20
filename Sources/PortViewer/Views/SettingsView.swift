import SwiftUI

/// Settings view for the app.
struct SettingsView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var currentVersion = "..."

    // MARK: - Body

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            favoritesTab
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }

            AboutView()
                .environmentObject(appState)
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 350)
        .task {
            currentVersion = await appState.getCurrentVersion()
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $appState.launchAtLogin.isEnabled)
                Toggle("Show only listening ports", isOn: $appState.showOnlyListening)
            } header: {
                Text("Startup")
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(currentVersion)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task { await appState.checkForUpdates() }
                } label: {
                    HStack {
                        Text("Check for Updates")
                        Spacer()
                        if appState.isCheckingForUpdates {
                            ProgressView()
                                .scaleEffect(0.6)
                        } else if appState.availableUpdate != nil {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .buttonStyle(.borderless)
            } header: {
                Text("Updates")
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Favorites Tab

    private var favoritesTab: some View {
        Form {
            Section {
                if appState.favorites.isEmpty {
                    Text("No pinned ports yet")
                        .foregroundStyle(.secondary)
                    Text("Click on a port and select Pin to add it here.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    ForEach(Array(appState.favorites).sorted(), id: \.self) { port in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                            Text("Port \(port)")
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Button {
                                appState.toggleFavorite(port)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text("Pinned Ports")
            } footer: {
                Text("Pinned ports appear at the top of the ports list.")
            }
        }
        .formStyle(.grouped)
    }
}
