import AppKit
import Foundation

/// Service for checking and handling app updates from GitHub releases.
public actor UpdateChecker {

    // MARK: - Types

    public struct Release: Sendable {
        public let version: String
        public let tagName: String
        public let htmlURL: URL
        public let downloadURL: URL?
        public let isPrerelease: Bool
        public let publishedAt: Date?
    }

    public enum UpdateError: Error, LocalizedError, Sendable {
        case networkError(String)
        case invalidResponse
        case noReleasesFound

        public var errorDescription: String? {
            switch self {
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidResponse:
                return "Invalid response from GitHub"
            case .noReleasesFound:
                return "No releases found"
            }
        }
    }

    // MARK: - Properties

    private let repoOwner = "CorvidLabs"
    private let repoName = "Ports"

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    // MARK: - Initializers

    public init() {}

    // MARK: - Public Methods

    /// Check for available updates.
    public func checkForUpdates() async throws -> Release? {
        let latestRelease = try await fetchLatestRelease()

        if isNewerVersion(latestRelease.version, than: currentVersion) {
            return latestRelease
        }

        return nil
    }

    /// Get the current app version.
    public func getCurrentVersion() -> String {
        currentVersion
    }

    /// Fetch the latest release from GitHub.
    public func fetchLatestRelease() async throws -> Release {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else {
            throw UpdateError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw UpdateError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UpdateError.noReleasesFound
        }

        return try parseRelease(from: data)
    }

    /// Open the releases page in browser.
    public func openReleasesPage() {
        let urlString = "https://github.com/\(repoOwner)/\(repoName)/releases"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    /// Open a specific release download.
    public func openDownload(_ release: Release) {
        if let downloadURL = release.downloadURL {
            NSWorkspace.shared.open(downloadURL)
        } else {
            NSWorkspace.shared.open(release.htmlURL)
        }
    }

    // MARK: - Private Methods

    private func parseRelease(from data: Data) throws -> Release {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String,
              let htmlURLString = json["html_url"] as? String,
              let htmlURL = URL(string: htmlURLString) else {
            throw UpdateError.invalidResponse
        }

        let version = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        let isPrerelease = json["prerelease"] as? Bool ?? false

        var downloadURL: URL?
        if let assets = json["assets"] as? [[String: Any]] {
            for asset in assets {
                if let name = asset["name"] as? String,
                   name.hasSuffix(".dmg"),
                   let urlString = asset["browser_download_url"] as? String,
                   let url = URL(string: urlString) {
                    downloadURL = url
                    break
                }
            }
        }

        var publishedAt: Date?
        if let dateString = json["published_at"] as? String {
            let formatter = ISO8601DateFormatter()
            publishedAt = formatter.date(from: dateString)
        }

        return Release(
            version: version,
            tagName: tagName,
            htmlURL: htmlURL,
            downloadURL: downloadURL,
            isPrerelease: isPrerelease,
            publishedAt: publishedAt
        )
    }

    private func isNewerVersion(_ new: String, than current: String) -> Bool {
        let newParts = parseVersion(new)
        let currentParts = parseVersion(current)

        for i in 0..<max(newParts.count, currentParts.count) {
            let newPart = i < newParts.count ? newParts[i] : 0
            let currentPart = i < currentParts.count ? currentParts[i] : 0

            if newPart > currentPart {
                return true
            } else if newPart < currentPart {
                return false
            }
        }

        return false
    }

    private func parseVersion(_ version: String) -> [Int] {
        let cleanVersion = version
            .replacingOccurrences(of: "-alpha", with: "")
            .replacingOccurrences(of: "-beta", with: "")
            .replacingOccurrences(of: "-rc", with: "")

        return cleanVersion.split(separator: ".").compactMap { Int($0) }
    }
}
