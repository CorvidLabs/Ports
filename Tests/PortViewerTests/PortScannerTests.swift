import Testing
@testable import PortViewer

@Suite("PortScanner Tests")
struct PortScannerTests {

    // MARK: - PortInfo Construction Tests

    @Suite("PortInfo Construction")
    struct ConstructionTests {

        @Test("PortInfo with all fields populated")
        func allFieldsPopulated() {
            let port = PortInfo(
                port: 8080,
                transport: .tcp,
                processName: "node",
                pid: 12345,
                user: "corvid",
                localAddress: "127.0.0.1:8080",
                remoteAddress: "192.168.1.100:54321",
                state: .established
            )
            #expect(port.port == 8080)
            #expect(port.transport == .tcp)
            #expect(port.processName == "node")
            #expect(port.pid == 12345)
            #expect(port.user == "corvid")
            #expect(port.localAddress == "127.0.0.1:8080")
            #expect(port.remoteAddress == "192.168.1.100:54321")
            #expect(port.state == .established)
        }

        @Test("PortInfo with minimal fields uses defaults")
        func minimalFields() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            #expect(port.port == 3000)
            #expect(port.transport == .tcp)
            #expect(port.processName == "node")
            #expect(port.pid == 1234)
            #expect(port.user == "")
            #expect(port.localAddress == "")
            #expect(port.remoteAddress == nil)
            #expect(port.state == nil)
        }

        @Test("PortInfo with TCP transport")
        func tcpTransport() {
            let port = PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 100)
            #expect(port.transport == .tcp)
            #expect(port.transport.rawValue == "TCP")
        }

        @Test("PortInfo with UDP transport")
        func udpTransport() {
            let port = PortInfo(port: 53, transport: .udp, processName: "mDNSResponder", pid: 200)
            #expect(port.transport == .udp)
            #expect(port.transport.rawValue == "UDP")
        }

        @Test("PortInfo with ESTABLISHED state and connection addresses")
        func establishedConnection() {
            let port = PortInfo(
                port: 443,
                transport: .tcp,
                processName: "curl",
                pid: 5678,
                user: "root",
                localAddress: "192.168.1.50:54321",
                remoteAddress: "93.184.216.34:443",
                state: .established
            )
            #expect(port.state == .established)
            #expect(port.remoteAddress == "93.184.216.34:443")
            #expect(port.localAddress == "192.168.1.50:54321")
        }
    }

    // MARK: - Sorting Tests

    @Suite("Sorting Behavior")
    struct SortingTests {

        @Test("PortInfo array sorts by port number ascending")
        func sortsByPortNumber() {
            let ports = [
                PortInfo(port: 8080, transport: .tcp, processName: "node", pid: 1),
                PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 2),
                PortInfo(port: 3000, transport: .tcp, processName: "bun", pid: 3),
                PortInfo(port: 443, transport: .tcp, processName: "nginx", pid: 4)
            ]
            let sorted = ports.sorted { $0.port < $1.port }
            #expect(sorted[0].port == 80)
            #expect(sorted[1].port == 443)
            #expect(sorted[2].port == 3000)
            #expect(sorted[3].port == 8080)
        }

        @Test("Single port array is already sorted")
        func singleElementSorted() {
            let ports = [PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1)]
            let sorted = ports.sorted { $0.port < $1.port }
            #expect(sorted.count == 1)
            #expect(sorted[0].port == 3000)
        }

        @Test("Already sorted array stays sorted")
        func alreadySorted() {
            let ports = [
                PortInfo(port: 22, transport: .tcp, processName: "sshd", pid: 1),
                PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 2),
                PortInfo(port: 443, transport: .tcp, processName: "nginx", pid: 3)
            ]
            let sorted = ports.sorted { $0.port < $1.port }
            #expect(sorted[0].port == 22)
            #expect(sorted[1].port == 80)
            #expect(sorted[2].port == 443)
        }
    }

    // MARK: - Deduplication Tests

    @Suite("Deduplication Logic")
    struct DeduplicationTests {

        @Test("Same port+transport+pid creates unique key")
        func uniqueKeyGeneration() {
            let port1 = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let port2 = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let key1 = "\(port1.port)-\(port1.transport.rawValue)-\(port1.pid)"
            let key2 = "\(port2.port)-\(port2.transport.rawValue)-\(port2.pid)"
            #expect(key1 == key2)
        }

        @Test("Different transport creates different key")
        func differentTransportKey() {
            let tcpPort = PortInfo(port: 53, transport: .tcp, processName: "dns", pid: 100)
            let udpPort = PortInfo(port: 53, transport: .udp, processName: "dns", pid: 100)
            let key1 = "\(tcpPort.port)-\(tcpPort.transport.rawValue)-\(tcpPort.pid)"
            let key2 = "\(udpPort.port)-\(udpPort.transport.rawValue)-\(udpPort.pid)"
            #expect(key1 != key2)
        }

        @Test("Different PID creates different key")
        func differentPidKey() {
            let port1 = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let port2 = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 5678)
            let key1 = "\(port1.port)-\(port1.transport.rawValue)-\(port1.pid)"
            let key2 = "\(port2.port)-\(port2.transport.rawValue)-\(port2.pid)"
            #expect(key1 != key2)
        }

        @Test("Deduplication with Set removes duplicates correctly")
        func deduplicationWithSet() {
            var seenPorts: Set<String> = []
            let ports = [
                PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234),
                PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234),
                PortInfo(port: 3000, transport: .udp, processName: "node", pid: 1234),
                PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 5678)
            ]

            var unique: [PortInfo] = []
            for port in ports {
                let key = "\(port.port)-\(port.transport.rawValue)-\(port.pid)"
                if !seenPorts.contains(key) {
                    seenPorts.insert(key)
                    unique.append(port)
                }
            }
            #expect(unique.count == 3)
        }
    }

    // MARK: - Edge Case Port Numbers

    @Suite("Edge Case Port Numbers")
    struct EdgeCasePortTests {

        @Test("Port 0 is valid")
        func portZero() {
            let port = PortInfo(port: 0, transport: .tcp, processName: "test", pid: 1)
            #expect(port.port == 0)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 1 is valid and privileged")
        func portOne() {
            let port = PortInfo(port: 1, transport: .tcp, processName: "test", pid: 1)
            #expect(port.port == 1)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 65535 is valid and not privileged")
        func portMax() {
            let port = PortInfo(port: 65535, transport: .tcp, processName: "test", pid: 1)
            #expect(port.port == 65535)
            #expect(port.isPrivileged == false)
        }
    }

    // MARK: - Category Detection for All Categories

    @Suite("Complete Category Detection")
    struct CompleteCategoryTests {

        // Dev processes
        @Test("Deno process is categorized as dev")
        func denoIsDev() {
            let port = PortInfo(port: 9000, transport: .tcp, processName: "deno", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Webpack process is categorized as dev")
        func webpackIsDev() {
            let port = PortInfo(port: 9000, transport: .tcp, processName: "webpack", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Vite process is categorized as dev")
        func viteIsDev() {
            let port = PortInfo(port: 5173, transport: .tcp, processName: "vite", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Python process is categorized as dev")
        func pythonIsDev() {
            let port = PortInfo(port: 9000, transport: .tcp, processName: "python3", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Docker process is categorized as dev")
        func dockerIsDev() {
            let port = PortInfo(port: 2375, transport: .tcp, processName: "docker", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Jupyter process is categorized as dev")
        func jupyterIsDev() {
            let port = PortInfo(port: 8888, transport: .tcp, processName: "jupyter-notebook", pid: 1234)
            #expect(port.category == .dev)
        }

        // Database processes
        @Test("MongoDB process is categorized as database")
        func mongoIsDatabase() {
            let port = PortInfo(port: 27017, transport: .tcp, processName: "mongod", pid: 1234)
            #expect(port.category == .database)
        }

        @Test("MySQL process is categorized as database")
        func mysqlIsDatabase() {
            let port = PortInfo(port: 3306, transport: .tcp, processName: "mysqld", pid: 1234)
            #expect(port.category == .database)
        }

        @Test("Elasticsearch process is categorized as database")
        func elasticsearchIsDatabase() {
            let port = PortInfo(port: 9200, transport: .tcp, processName: "elasticsearch", pid: 1234)
            #expect(port.category == .database)
        }

        @Test("Database port without matching process name")
        func dbPortDetection() {
            let port = PortInfo(port: 5432, transport: .tcp, processName: "unknown_app", pid: 1234)
            #expect(port.category == .database)
        }

        // Web processes
        @Test("Apache process is categorized as web")
        func apacheIsWeb() {
            let port = PortInfo(port: 8082, transport: .tcp, processName: "apache2", pid: 1234)
            #expect(port.category == .web)
        }

        @Test("Caddy process is categorized as web")
        func caddyIsWeb() {
            let port = PortInfo(port: 2019, transport: .tcp, processName: "caddy", pid: 1234)
            #expect(port.category == .web)
        }

        @Test("httpd process is categorized as web")
        func httpdIsWeb() {
            let port = PortInfo(port: 8082, transport: .tcp, processName: "httpd", pid: 1234)
            #expect(port.category == .web)
        }

        @Test("Port 443 is categorized as web regardless of process")
        func webPortDetection() {
            let port = PortInfo(port: 443, transport: .tcp, processName: "unknown_app", pid: 1234)
            #expect(port.category == .web)
        }

        // Gaming processes
        @Test("Steam helper is categorized as gaming")
        func steamHelperIsGaming() {
            let port = PortInfo(port: 27016, transport: .tcp, processName: "steamwebhelper", pid: 1234)
            #expect(port.category == .gaming)
        }

        @Test("Minecraft port is categorized as gaming")
        func minecraftPortIsGaming() {
            // Use a process name that doesn't match dev keywords; port 25565 is a gaming port
            let port = PortInfo(port: 25565, transport: .tcp, processName: "unknown_mc", pid: 1234)
            #expect(port.category == .gaming)
        }

        // Media processes
        @Test("Plex process is categorized as media")
        func plexIsMedia() {
            let port = PortInfo(port: 32400, transport: .tcp, processName: "plexmediaserver", pid: 1234)
            #expect(port.category == .media)
        }

        @Test("VLC process is categorized as media")
        func vlcIsMedia() {
            let port = PortInfo(port: 9000, transport: .tcp, processName: "vlc", pid: 1234)
            #expect(port.category == .media)
        }

        @Test("Media port detected by port number")
        func mediaPortDetection() {
            let port = PortInfo(port: 32400, transport: .tcp, processName: "unknown_app", pid: 1234)
            #expect(port.category == .media)
        }

        // macOS processes
        @Test("sharingd is categorized as macos")
        func sharingdIsMacos() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "sharingd", pid: 1234)
            #expect(port.category == .macos)
        }

        @Test("airplayxpchelper is categorized as macos")
        func airplayxpchelperIsMacos() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "airplayxpchelper", pid: 1234)
            #expect(port.category == .macos)
        }

        @Test("mDNSResponder is categorized as macos")
        func mdnsResponderIsMacos() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "mDNSResponder", pid: 1234)
            #expect(port.category == .macos)
        }

        @Test("configd is categorized as macos")
        func configdIsMacos() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "configd", pid: 1234)
            #expect(port.category == .macos)
        }

        // Comms processes
        @Test("Zoom is categorized as comms")
        func zoomIsComms() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "zoom.us", pid: 1234)
            #expect(port.category == .comms)
        }

        @Test("SSH port is categorized as comms")
        func sshPortIsComms() {
            let port = PortInfo(port: 22, transport: .tcp, processName: "sshd", pid: 1234)
            #expect(port.category == .comms)
        }

        @Test("Signal is categorized as comms")
        func signalIsComms() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "signal-desktop", pid: 1234)
            #expect(port.category == .comms)
        }

        @Test("Email port 587 is categorized as comms")
        func emailPortIsComms() {
            let port = PortInfo(port: 587, transport: .tcp, processName: "unknown_app", pid: 1234)
            #expect(port.category == .comms)
        }

        // Other
        @Test("Unknown process on unknown port is other")
        func unknownIsOther() {
            let port = PortInfo(port: 54321, transport: .tcp, processName: "foobar_app", pid: 1234)
            #expect(port.category == .other)
        }
    }

    // MARK: - Risk Assessment Combinations

    @Suite("Risk Assessment Combinations")
    struct RiskCombinationTests {

        @Test("Database on localhost is safe")
        func databaseLocalhostSafe() {
            let port = PortInfo(
                port: 5432,
                transport: .tcp,
                processName: "postgres",
                pid: 1234,
                localAddress: "127.0.0.1:5432"
            )
            #expect(port.risk == .safe)
        }

        @Test("Database exposed externally is normal")
        func databaseExposedNormal() {
            let port = PortInfo(
                port: 5432,
                transport: .tcp,
                processName: "postgres",
                pid: 1234,
                localAddress: "*:5432"
            )
            #expect(port.risk == .normal)
        }

        @Test("Web server on localhost is safe")
        func webLocalhostSafe() {
            let port = PortInfo(
                port: 80,
                transport: .tcp,
                processName: "nginx",
                pid: 1234,
                localAddress: "127.0.0.1:80"
            )
            #expect(port.risk == .safe)
        }

        @Test("Web server exposed externally is normal")
        func webExposedNormal() {
            let port = PortInfo(
                port: 80,
                transport: .tcp,
                processName: "nginx",
                pid: 1234,
                localAddress: "*:80"
            )
            #expect(port.risk == .normal)
        }

        @Test("Gaming on localhost is safe")
        func gamingLocalhostSafe() {
            let port = PortInfo(
                port: 27015,
                transport: .tcp,
                processName: "steam",
                pid: 1234,
                localAddress: "127.0.0.1:27015"
            )
            #expect(port.risk == .safe)
        }

        @Test("Media on localhost is safe")
        func mediaLocalhostSafe() {
            let port = PortInfo(
                port: 32400,
                transport: .tcp,
                processName: "plex",
                pid: 1234,
                localAddress: "127.0.0.1:32400"
            )
            #expect(port.risk == .safe)
        }

        @Test("Comms exposed externally is normal")
        func commsExposedNormal() {
            let port = PortInfo(
                port: 22,
                transport: .tcp,
                processName: "sshd",
                pid: 1234,
                localAddress: "*:22"
            )
            #expect(port.risk == .normal)
        }

        @Test("macOS service exposed is normal")
        func macosExposedNormal() {
            let port = PortInfo(
                port: 50000,
                transport: .tcp,
                processName: "rapportd",
                pid: 1234,
                localAddress: "*:50000"
            )
            #expect(port.risk == .normal)
        }

        @Test("Unknown process on localhost is unknown risk")
        func unknownLocalhostUnknown() {
            let port = PortInfo(
                port: 54321,
                transport: .tcp,
                processName: "mystery_app",
                pid: 1234,
                localAddress: "127.0.0.1:54321"
            )
            #expect(port.risk == .unknown)
        }

        @Test("Unknown process exposed is attention")
        func unknownExposedAttention() {
            let port = PortInfo(
                port: 54321,
                transport: .tcp,
                processName: "mystery_app",
                pid: 1234,
                localAddress: "0.0.0.0:54321"
            )
            #expect(port.risk == .attention)
        }
    }

    // MARK: - Well-Known Port Detection

    @Suite("Well-Known Port Detection")
    struct WellKnownPortTests {

        @Test("SSH port 22 is well-known")
        func sshIsWellKnown() {
            let port = PortInfo(port: 22, transport: .tcp, processName: "sshd", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("HTTP port 80 is well-known")
        func httpIsWellKnown() {
            let port = PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("HTTPS port 443 is well-known")
        func httpsIsWellKnown() {
            let port = PortInfo(port: 443, transport: .tcp, processName: "nginx", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("Database ports are well-known")
        func dbPortsAreWellKnown() {
            let dbPorts = [3306, 5432, 6379, 27017]
            for portNum in dbPorts {
                let port = PortInfo(port: portNum, transport: .tcp, processName: "db", pid: 1)
                #expect(port.isWellKnown == true, "Port \(portNum) should be well-known")
            }
        }

        @Test("Common dev ports are well-known")
        func devPortsAreWellKnown() {
            let devPorts = [3000, 4000, 5000, 8000, 8080]
            for portNum in devPorts {
                let port = PortInfo(port: portNum, transport: .tcp, processName: "app", pid: 1)
                #expect(port.isWellKnown == true, "Port \(portNum) should be well-known")
            }
        }

        @Test("Random high port is not well-known")
        func randomPortNotWellKnown() {
            let port = PortInfo(port: 54321, transport: .tcp, processName: "app", pid: 1)
            #expect(port.isWellKnown == false)
        }

        @Test("DNS port 53 is well-known")
        func dnsIsWellKnown() {
            let port = PortInfo(port: 53, transport: .udp, processName: "dns", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("SMTP port 25 is well-known")
        func smtpIsWellKnown() {
            let port = PortInfo(port: 25, transport: .tcp, processName: "sendmail", pid: 1)
            #expect(port.isWellKnown == true)
        }
    }

    // MARK: - ScanError Tests

    @Suite("ScanError Descriptions")
    struct ScanErrorTests {

        @Test("processExecutionFailed has correct description")
        func processExecutionFailedDescription() {
            let error = PortScanner.ScanError.processExecutionFailed("lsof not found")
            #expect(error.errorDescription?.contains("lsof") == true)
            #expect(error.errorDescription?.contains("lsof not found") == true)
        }

        @Test("parsingFailed has correct description")
        func parsingFailedDescription() {
            let error = PortScanner.ScanError.parsingFailed("unexpected format")
            #expect(error.errorDescription?.contains("parse") == true)
            #expect(error.errorDescription?.contains("unexpected format") == true)
        }
    }
}
