import Foundation

/// Utility for comparing semantic version strings.
public enum VersionComparator {

    // MARK: - Public Methods

    /// Compares two version strings and returns true if the new version is greater.
    /// - Parameters:
    ///   - new: The new version string (e.g., "1.2.0" or "1.2.0-alpha")
    ///   - current: The current version string
    /// - Returns: True if new version is greater than current
    public static func isNewer(_ new: String, than current: String) -> Bool {
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

    /// Parses a version string into its numeric components.
    /// - Parameter version: The version string (e.g., "1.2.0" or "1.2.0-beta.1")
    /// - Returns: Array of version components as integers
    public static func parseVersion(_ version: String) -> [Int] {
        // Strip prerelease suffix (everything after first hyphen)
        let baseVersion: String
        if let hyphenIndex = version.firstIndex(of: "-") {
            baseVersion = String(version[..<hyphenIndex])
        } else {
            baseVersion = version
        }

        return baseVersion.split(separator: ".").compactMap { Int($0) }
    }
}
