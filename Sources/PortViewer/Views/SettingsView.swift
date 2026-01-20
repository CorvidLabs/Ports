import SwiftUI

/// Settings view for the app.
struct SettingsView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                Toggle("Show only listening ports by default", isOn: $appState.showOnlyListening)
            } header: {
                Text("Display")
            }

            Section {
                if appState.favorites.isEmpty {
                    Text("No favorite ports yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(appState.favorites).sorted(), id: \.self) { port in
                        HStack {
                            Text("Port \(port)")
                            Spacer()
                            Button("Remove") {
                                appState.toggleFavorite(port)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.red)
                        }
                    }
                }
            } header: {
                Text("Favorites")
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                Link("View on GitHub", destination: URL(string: "https://github.com")!)
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
    }
}
