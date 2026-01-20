import SwiftUI

/// Detailed view for a single port.
struct PortDetailView: View {

    // MARK: - Properties

    let port: PortInfo
    let onKill: () -> Void
    let onForceKill: () -> Void
    let onToggleFavorite: () -> Void
    let isFavorite: Bool

    private let mono = Font.system(.body, design: .monospaced)
    private let monoSmall = Font.system(.caption, design: .monospaced)
    private let accent = Color(red: 0.4, green: 0.9, blue: 0.6)

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: port.category.icon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(port.processName)
                        .font(.system(.headline, design: .monospaced))
                    Text("Port \(port.port)")
                        .font(monoSmall)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                riskBadge
            }

            Divider()

            // Details grid
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    detailLabel("Transport")
                    Text(port.transport.rawValue)
                        .font(mono)
                        .foregroundStyle(port.transport == .tcp ? .cyan : .orange)
                }

                GridRow {
                    detailLabel("PID")
                    HStack {
                        Text(String(port.pid))
                            .font(mono)
                        Button {
                            copyToClipboard(String(port.pid))
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }

                GridRow {
                    detailLabel("User")
                    Text(port.user)
                        .font(mono)
                }

                GridRow {
                    detailLabel("Local Address")
                    Text(port.localAddress)
                        .font(mono)
                        .foregroundStyle(port.isLocalOnly ? .green : .primary)
                }

                if let remoteAddress = port.remoteAddress, !remoteAddress.isEmpty, remoteAddress != "*:*" {
                    GridRow {
                        detailLabel("Remote")
                        Text(remoteAddress)
                            .font(mono)
                    }
                }

                if let state = port.state {
                    GridRow {
                        detailLabel("State")
                        Text(state.rawValue)
                            .font(mono)
                            .foregroundStyle(.secondary)
                    }
                }

                GridRow {
                    detailLabel("Exposure")
                    HStack(spacing: 4) {
                        Image(systemName: port.isLocalOnly ? "lock.fill" : "network")
                            .font(.caption)
                        Text(port.exposureLabel)
                            .font(mono)
                    }
                    .foregroundStyle(port.isLocalOnly ? .green : .orange)
                }

                if port.isPrivileged {
                    GridRow {
                        detailLabel("Privileged")
                        Text("Yes (root required)")
                            .font(mono)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button {
                    onToggleFavorite()
                } label: {
                    Label(isFavorite ? "Unpin" : "Pin", systemImage: isFavorite ? "star.fill" : "star")
                        .font(monoSmall)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(role: .destructive) {
                    onKill()
                } label: {
                    Label("Kill", systemImage: "xmark.circle")
                        .font(monoSmall)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    onForceKill()
                } label: {
                    Label("Force Kill", systemImage: "bolt.circle")
                        .font(monoSmall)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 280)
    }

    // MARK: - Components

    private var riskBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: port.risk.icon)
            Text(port.risk.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(riskColor.opacity(0.15))
        .foregroundStyle(riskColor)
        .clipShape(Capsule())
    }

    private func detailLabel(_ text: String) -> some View {
        Text(text)
            .font(monoSmall)
            .foregroundStyle(.secondary)
            .frame(width: 80, alignment: .trailing)
    }

    // MARK: - Colors

    private var categoryColor: Color {
        switch port.category {
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

    private var riskColor: Color {
        switch port.risk {
        case .safe: return .green
        case .normal: return .blue
        case .attention: return .orange
        case .unknown: return .secondary
        }
    }

    // MARK: - Helpers

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
