import Testing
@testable import PortViewer

@Suite("PortInfo Tests")
struct PortInfoTests {

    // MARK: - Category Detection Tests

    @Suite("Category Detection")
    struct CategoryTests {

        @Test("Node process is categorized as dev")
        func nodeIsDev() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Bun process is categorized as dev")
        func bunIsDev() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "bun", pid: 1234)
            #expect(port.category == .dev)
        }

        @Test("Common dev ports are categorized as dev")
        func devPortsAreDev() {
            let devPorts = [3000, 3001, 4200, 5173, 8080, 8888]
            for portNumber in devPorts {
                let port = PortInfo(port: portNumber, transport: .tcp, processName: "unknown", pid: 1234)
                #expect(port.category == .dev, "Port \(portNumber) should be dev")
            }
        }

        @Test("PostgreSQL process is categorized as database")
        func postgresIsDatabase() {
            let port = PortInfo(port: 5432, transport: .tcp, processName: "postgres", pid: 1234)
            #expect(port.category == .database)
        }

        @Test("Redis process is categorized as database")
        func redisIsDatabase() {
            let port = PortInfo(port: 6379, transport: .tcp, processName: "redis-server", pid: 1234)
            #expect(port.category == .database)
        }

        @Test("nginx process is categorized as web")
        func nginxIsWeb() {
            let port = PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 1234)
            #expect(port.category == .web)
        }

        @Test("rapportd is categorized as macos")
        func rapportdIsMacos() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "rapportd", pid: 1234)
            #expect(port.category == .macos)
        }

        @Test("Steam is categorized as gaming")
        func steamIsGaming() {
            let port = PortInfo(port: 27015, transport: .tcp, processName: "steam", pid: 1234)
            #expect(port.category == .gaming)
        }

        @Test("Spotify is categorized as media")
        func spotifyIsMedia() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "Spotify", pid: 1234)
            #expect(port.category == .media)
        }

        @Test("Slack is categorized as comms")
        func slackIsComms() {
            let port = PortInfo(port: 50000, transport: .tcp, processName: "Slack", pid: 1234)
            #expect(port.category == .comms)
        }

        @Test("Unknown process is categorized as other")
        func unknownIsOther() {
            let port = PortInfo(port: 12345, transport: .tcp, processName: "myapp", pid: 1234)
            #expect(port.category == .other)
        }
    }

    // MARK: - Risk Assessment Tests

    @Suite("Risk Assessment")
    struct RiskTests {

        @Test("macOS service on localhost is safe")
        func macosLocalhostIsSafe() {
            let port = PortInfo(
                port: 50000,
                transport: .tcp,
                processName: "rapportd",
                pid: 1234,
                localAddress: "127.0.0.1:50000"
            )
            #expect(port.risk == .safe)
        }

        @Test("Dev process on localhost is safe")
        func devLocalhostIsSafe() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "127.0.0.1:3000"
            )
            #expect(port.risk == .safe)
        }

        @Test("Dev process on all interfaces is normal")
        func devExposedIsNormal() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "*:3000"
            )
            #expect(port.risk == .normal)
        }

        @Test("Unknown process exposed is attention")
        func unknownExposedIsAttention() {
            let port = PortInfo(
                port: 12345,
                transport: .tcp,
                processName: "mystery",
                pid: 1234,
                localAddress: "*:12345"
            )
            #expect(port.risk == .attention)
        }

        @Test("Unknown process on localhost is unknown risk")
        func unknownLocalhostIsUnknown() {
            let port = PortInfo(
                port: 12345,
                transport: .tcp,
                processName: "mystery",
                pid: 1234,
                localAddress: "127.0.0.1:12345"
            )
            #expect(port.risk == .unknown)
        }
    }

    // MARK: - Exposure Tests

    @Suite("Exposure Detection")
    struct ExposureTests {

        @Test("127.0.0.1 is local only")
        func ipv4LocalhostIsLocal() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "127.0.0.1:3000"
            )
            #expect(port.isLocalOnly == true)
            #expect(port.isExposed == false)
            #expect(port.exposureLabel == "127")
        }

        @Test("::1 is local only")
        func ipv6LocalhostIsLocal() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "[::1]:3000"
            )
            #expect(port.isLocalOnly == true)
            #expect(port.isExposed == false)
        }

        @Test("* is exposed")
        func wildcardIsExposed() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "*:3000"
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
            #expect(port.exposureLabel == "*")
        }

        @Test("0.0.0.0 is exposed")
        func zeroAddressIsExposed() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "0.0.0.0:3000"
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
        }
    }

    // MARK: - Privileged Port Tests

    @Suite("Privileged Ports")
    struct PrivilegedTests {

        @Test("Port 80 is privileged")
        func port80IsPrivileged() {
            let port = PortInfo(port: 80, transport: .tcp, processName: "nginx", pid: 1234)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 443 is privileged")
        func port443IsPrivileged() {
            let port = PortInfo(port: 443, transport: .tcp, processName: "nginx", pid: 1234)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 1023 is privileged")
        func port1023IsPrivileged() {
            let port = PortInfo(port: 1023, transport: .tcp, processName: "app", pid: 1234)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 1024 is not privileged")
        func port1024IsNotPrivileged() {
            let port = PortInfo(port: 1024, transport: .tcp, processName: "app", pid: 1234)
            #expect(port.isPrivileged == false)
        }

        @Test("Port 3000 is not privileged")
        func port3000IsNotPrivileged() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "node", pid: 1234)
            #expect(port.isPrivileged == false)
        }
    }

    // MARK: - State Parsing Tests

    @Suite("State Parsing")
    struct StateTests {

        @Test("LISTEN state parses correctly")
        func listenState() {
            let state = PortInfo.State(rawValue: "LISTEN")
            #expect(state == .listen)
        }

        @Test("ESTABLISHED state parses correctly")
        func establishedState() {
            let state = PortInfo.State(rawValue: "ESTABLISHED")
            #expect(state == .established)
        }

        @Test("Case insensitive parsing")
        func caseInsensitive() {
            let state = PortInfo.State(rawValue: "listen")
            #expect(state == .listen)
        }

        @Test("Unknown state returns unknown")
        func unknownState() {
            let state = PortInfo.State(rawValue: "INVALID")
            #expect(state == .unknown)
        }
    }
}
