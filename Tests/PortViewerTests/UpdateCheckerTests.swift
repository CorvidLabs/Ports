import Testing
import Foundation
@testable import PortViewer

@Suite("UpdateChecker Tests")
struct UpdateCheckerTests {

    // MARK: - Release Model Tests

    @Suite("Release Model")
    struct ReleaseModelTests {

        @Test("Release struct initialization with all fields")
        func releaseAllFields() {
            let release = UpdateChecker.Release(
                version: "1.2.0",
                tagName: "v1.2.0",
                htmlURL: URL(string: "https://github.com/CorvidLabs/Ports/releases/tag/v1.2.0")!,
                downloadURL: URL(string: "https://github.com/CorvidLabs/Ports/releases/download/v1.2.0/Ports.dmg")!,
                isPrerelease: false,
                publishedAt: Date()
            )
            #expect(release.version == "1.2.0")
            #expect(release.tagName == "v1.2.0")
            #expect(release.isPrerelease == false)
            #expect(release.downloadURL != nil)
            #expect(release.publishedAt != nil)
        }

        @Test("Release struct with nil downloadURL")
        func releaseNoDownload() {
            let release = UpdateChecker.Release(
                version: "0.1.0",
                tagName: "v0.1.0",
                htmlURL: URL(string: "https://github.com/CorvidLabs/Ports/releases/tag/v0.1.0")!,
                downloadURL: nil,
                isPrerelease: false,
                publishedAt: nil
            )
            #expect(release.downloadURL == nil)
            #expect(release.publishedAt == nil)
        }

        @Test("Release struct with prerelease flag")
        func prereleaseFlag() {
            let release = UpdateChecker.Release(
                version: "2.0.0-beta.1",
                tagName: "v2.0.0-beta.1",
                htmlURL: URL(string: "https://github.com/CorvidLabs/Ports/releases/tag/v2.0.0-beta.1")!,
                downloadURL: nil,
                isPrerelease: true,
                publishedAt: nil
            )
            #expect(release.isPrerelease == true)
            #expect(release.version == "2.0.0-beta.1")
        }

        @Test("Release version without v prefix")
        func versionWithoutPrefix() {
            let release = UpdateChecker.Release(
                version: "1.0.0",
                tagName: "1.0.0",
                htmlURL: URL(string: "https://github.com/example/repo/releases/tag/1.0.0")!,
                downloadURL: nil,
                isPrerelease: false,
                publishedAt: nil
            )
            #expect(release.version == "1.0.0")
            #expect(release.tagName == "1.0.0")
        }

        @Test("Release htmlURL is accessible")
        func htmlURLAccessible() {
            let url = URL(string: "https://github.com/CorvidLabs/Ports/releases/tag/v1.0.0")!
            let release = UpdateChecker.Release(
                version: "1.0.0",
                tagName: "v1.0.0",
                htmlURL: url,
                downloadURL: nil,
                isPrerelease: false,
                publishedAt: nil
            )
            #expect(release.htmlURL == url)
            #expect(release.htmlURL.absoluteString.contains("github.com"))
        }
    }

    // MARK: - Version Comparison with Releases

    @Suite("Version Comparison with Release Versions")
    struct VersionComparisonTests {

        @Test("Release version newer than current triggers update")
        func newerRelease() {
            let releaseVersion = "1.1.0"
            let currentVersion = "1.0.0"
            #expect(VersionComparator.isNewer(releaseVersion, than: currentVersion) == true)
        }

        @Test("Release version same as current does not trigger update")
        func sameRelease() {
            let releaseVersion = "1.0.0"
            let currentVersion = "1.0.0"
            #expect(VersionComparator.isNewer(releaseVersion, than: currentVersion) == false)
        }

        @Test("Release version older than current does not trigger update")
        func olderRelease() {
            let releaseVersion = "0.9.0"
            let currentVersion = "1.0.0"
            #expect(VersionComparator.isNewer(releaseVersion, than: currentVersion) == false)
        }

        @Test("Prerelease version comparison with release version")
        func prereleaseVsRelease() {
            // A 2.0.0-beta should have same base version as 2.0.0
            #expect(VersionComparator.isNewer("2.0.0-beta", than: "1.9.9") == true)
            #expect(VersionComparator.isNewer("2.0.0-beta", than: "2.0.0") == false)
        }

        @Test("Version from tag name with v prefix stripped")
        func tagVersionStripping() {
            let tagName = "v1.2.3"
            let version = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
            #expect(version == "1.2.3")
            #expect(VersionComparator.isNewer(version, than: "1.2.2") == true)
        }

        @Test("Version from tag name without v prefix")
        func tagVersionNoPrefix() {
            let tagName = "1.2.3"
            let version = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
            #expect(version == "1.2.3")
        }
    }

    // MARK: - UpdateError Tests

    @Suite("UpdateError Descriptions")
    struct UpdateErrorTests {

        @Test("networkError contains message")
        func networkErrorDescription() {
            let error = UpdateChecker.UpdateError.networkError("Connection timed out")
            #expect(error.errorDescription?.contains("Connection timed out") == true)
            #expect(error.errorDescription?.contains("Network error") == true)
        }

        @Test("invalidResponse has description")
        func invalidResponseDescription() {
            let error = UpdateChecker.UpdateError.invalidResponse
            #expect(error.errorDescription?.contains("Invalid response") == true)
        }

        @Test("noReleasesFound has description")
        func noReleasesFoundDescription() {
            let error = UpdateChecker.UpdateError.noReleasesFound
            #expect(error.errorDescription?.contains("No releases found") == true)
        }

        @Test("All error types have non-nil descriptions")
        func allErrorsHaveDescriptions() {
            let errors: [UpdateChecker.UpdateError] = [
                .networkError("test"),
                .invalidResponse,
                .noReleasesFound
            ]
            for error in errors {
                #expect(error.errorDescription != nil)
                #expect(error.errorDescription?.isEmpty == false)
            }
        }
    }
}
