import Testing
@testable import PortViewer

@Suite("VersionComparator Tests")
struct VersionComparatorTests {

    // MARK: - Version Parsing Tests

    @Suite("Version Parsing")
    struct ParsingTests {

        @Test("Simple version parses correctly")
        func simpleVersion() {
            let parts = VersionComparator.parseVersion("1.2.3")
            #expect(parts == [1, 2, 3])
        }

        @Test("Two-part version parses correctly")
        func twoPartVersion() {
            let parts = VersionComparator.parseVersion("1.0")
            #expect(parts == [1, 0])
        }

        @Test("Single number parses correctly")
        func singleNumber() {
            let parts = VersionComparator.parseVersion("5")
            #expect(parts == [5])
        }

        @Test("Alpha suffix is stripped")
        func alphaStripped() {
            let parts = VersionComparator.parseVersion("1.2.0-alpha")
            #expect(parts == [1, 2, 0])
        }

        @Test("Beta suffix is stripped")
        func betaStripped() {
            let parts = VersionComparator.parseVersion("1.2.0-beta")
            #expect(parts == [1, 2, 0])
        }

        @Test("RC suffix is stripped")
        func rcStripped() {
            let parts = VersionComparator.parseVersion("1.2.0-rc1")
            #expect(parts == [1, 2, 0])
        }

        @Test("Alpha with number suffix is stripped correctly")
        func alphaWithNumber() {
            let parts = VersionComparator.parseVersion("1.2.0-alpha.1")
            #expect(parts == [1, 2, 0])
        }

        @Test("Complex prerelease suffix is stripped")
        func complexPrerelease() {
            let parts = VersionComparator.parseVersion("2.0.0-beta.2.hotfix.3")
            #expect(parts == [2, 0, 0])
        }

        @Test("Large version numbers parse correctly")
        func largeNumbers() {
            let parts = VersionComparator.parseVersion("100.200.300")
            #expect(parts == [100, 200, 300])
        }
    }

    // MARK: - Version Comparison Tests

    @Suite("Version Comparison")
    struct ComparisonTests {

        @Test("Higher major version is newer")
        func higherMajor() {
            #expect(VersionComparator.isNewer("2.0.0", than: "1.0.0") == true)
        }

        @Test("Higher minor version is newer")
        func higherMinor() {
            #expect(VersionComparator.isNewer("1.2.0", than: "1.1.0") == true)
        }

        @Test("Higher patch version is newer")
        func higherPatch() {
            #expect(VersionComparator.isNewer("1.0.2", than: "1.0.1") == true)
        }

        @Test("Same version is not newer")
        func sameVersion() {
            #expect(VersionComparator.isNewer("1.0.0", than: "1.0.0") == false)
        }

        @Test("Lower version is not newer")
        func lowerVersion() {
            #expect(VersionComparator.isNewer("1.0.0", than: "2.0.0") == false)
        }

        @Test("Different length versions compare correctly")
        func differentLengths() {
            #expect(VersionComparator.isNewer("1.0.1", than: "1.0") == true)
            #expect(VersionComparator.isNewer("1.0", than: "1.0.0") == false)
            #expect(VersionComparator.isNewer("1.0.0", than: "1.0") == false)
        }

        @Test("Prerelease suffix is ignored in comparison")
        func prereleaseIgnored() {
            // 1.1.0 is newer than 1.0.0, regardless of prerelease suffix
            #expect(VersionComparator.isNewer("1.1.0-alpha", than: "1.0.0") == true)
            // Same base version, neither is newer
            #expect(VersionComparator.isNewer("1.0.0-alpha", than: "1.0.0") == false)
            #expect(VersionComparator.isNewer("1.0.0", than: "1.0.0-alpha") == false)
        }

        @Test("Real-world update scenario")
        func realWorldUpdate() {
            // Current version is 0.3.0-alpha, checking against new releases
            #expect(VersionComparator.isNewer("0.3.0", than: "0.3.0-alpha") == false)
            #expect(VersionComparator.isNewer("0.3.1", than: "0.3.0-alpha") == true)
            #expect(VersionComparator.isNewer("0.4.0", than: "0.3.0-alpha") == true)
            #expect(VersionComparator.isNewer("1.0.0", than: "0.3.0-alpha") == true)
        }

        @Test("Zero versions compare correctly")
        func zeroVersions() {
            #expect(VersionComparator.isNewer("0.0.1", than: "0.0.0") == true)
            #expect(VersionComparator.isNewer("0.1.0", than: "0.0.9") == true)
        }
    }
}
