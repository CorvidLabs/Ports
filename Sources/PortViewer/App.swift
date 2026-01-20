import SwiftUI

@main
struct PortViewerApp: App {

    // MARK: - Properties

    @StateObject private var appState = AppState()

    // MARK: - Body

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Label {
                Text("Ports")
            } icon: {
                Image(systemName: "network")
            }
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Window("Code Review", id: "code-review") {
            CodeReviewView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

// MARK: - App State

/// Main application state managing ports, settings, and services.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Constants

    private enum StorageKey {
        static let favorites = "favorites"
    }

    // MARK: - Published Properties

    @Published var ports: [PortInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var favorites: Set<Int> = []
    @Published var showOnlyListening = true
    @Published var availableUpdate: UpdateChecker.Release?
    @Published var isCheckingForUpdates = false

    // MARK: - Services

    let scanner = PortScanner()
    let killer = ProcessKiller()
    let updateChecker = UpdateChecker()
    var launchAtLogin = LaunchAtLogin()

    // MARK: - Computed Properties

    var filteredPorts: [PortInfo] {
        var result = ports

        if showOnlyListening {
            result = result.filter { $0.state == .listen || $0.state == nil }
        }

        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { port in
                port.processName.lowercased().contains(lowercasedSearch) ||
                String(port.port).contains(lowercasedSearch)
            }
        }

        return result
    }

    var groupedPorts: [(category: PortInfo.Category, ports: [PortInfo])] {
        let grouped = Dictionary(grouping: filteredPorts) { $0.category }
        return PortInfo.Category.allCases
            .compactMap { category in
                guard let ports = grouped[category], !ports.isEmpty else { return nil }
                return (category: category, ports: ports.sorted { $0.port < $1.port })
            }
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    var favoritePorts: [PortInfo] {
        filteredPorts.filter { favorites.contains($0.port) }.sorted { $0.port < $1.port }
    }

    var listeningCount: Int {
        ports.filter { $0.state == .listen || $0.state == nil }.count
    }

    // MARK: - Initializers

    init() {
        loadFavorites()
        Task {
            await refresh()
            await checkForUpdates()
        }
    }

    // MARK: - Public Methods

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            ports = try await scanner.scan()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func killProcess(_ port: PortInfo, force: Bool = false) async -> Bool {
        do {
            if force {
                try await killer.forceKill(pid: port.pid, processName: port.processName)
            } else {
                try await killer.kill(pid: port.pid, processName: port.processName)
            }
            await refresh()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func toggleFavorite(_ port: Int) {
        if favorites.contains(port) {
            favorites.remove(port)
        } else {
            favorites.insert(port)
        }
        saveFavorites()
    }

    func isFavorite(_ port: Int) -> Bool {
        favorites.contains(port)
    }

    // MARK: - Private Methods

    private func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: StorageKey.favorites) as? [Int] {
            favorites = Set(data)
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: StorageKey.favorites)
    }

    // MARK: - Update Methods

    func checkForUpdates() async {
        isCheckingForUpdates = true

        do {
            availableUpdate = try await updateChecker.checkForUpdates()
        } catch {
            // Silently fail - updates are optional
        }

        isCheckingForUpdates = false
    }

    func downloadUpdate() async {
        guard let update = availableUpdate else { return }
        await updateChecker.openDownload(update)
    }

    func openReleasesPage() async {
        await updateChecker.openReleasesPage()
    }

    func getCurrentVersion() async -> String {
        await updateChecker.getCurrentVersion()
    }

    func dismissUpdate() {
        availableUpdate = nil
    }
}
