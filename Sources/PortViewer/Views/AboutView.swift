import SwiftUI

/// About view displaying app information.
internal struct AboutView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var currentVersion = "..."

    private let accent = Color(red: 0.4, green: 0.9, blue: 0.6)

    // MARK: - Body

    internal var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(accent.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "network")
                    .font(.system(size: 36))
                    .foregroundStyle(accent)
            }

            // App name
            Text("Ports")
                .font(.system(.title, design: .monospaced, weight: .bold))

            // Version
            Text("v\(currentVersion)")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)

            // Description
            Text("A lightweight menu bar utility for\nmonitoring open network ports.")
                .font(.system(.caption, design: .default))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()
                .padding(.horizontal, 40)

            // Links
            VStack(spacing: 8) {
                Link(destination: URL(string: "https://github.com/CorvidLabs/Ports")!) {
                    Label("GitHub Repository", systemImage: "link")
                        .font(.system(.caption, design: .monospaced))
                }

                Link(destination: URL(string: "https://github.com/CorvidLabs/Ports/issues")!) {
                    Label("Report an Issue", systemImage: "exclamationmark.bubble")
                        .font(.system(.caption, design: .monospaced))
                }

                Link(destination: URL(string: "https://github.com/CorvidLabs/Ports/releases")!) {
                    Label("Release Notes", systemImage: "doc.text")
                        .font(.system(.caption, design: .monospaced))
                }
            }

            Spacer()

            // Copyright
            Text("© 2025 CorvidLabs")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.quaternary)
        }
        .padding(.vertical, 24)
        .frame(width: 280, height: 340)
        .task {
            currentVersion = await appState.getCurrentVersion()
        }
    }
}
