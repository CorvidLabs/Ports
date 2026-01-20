import Foundation
import ServiceManagement

/// Manages the app's launch at login setting.
@MainActor
public final class LaunchAtLogin: ObservableObject {

    // MARK: - Properties

    /// Whether the app is set to launch at login.
    @Published public var isEnabled: Bool {
        didSet {
            if isEnabled != oldValue {
                updateLaunchAtLogin()
            }
        }
    }

    // MARK: - Initializers

    public init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Private Methods

    private func updateLaunchAtLogin() {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Revert on failure
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }
}
