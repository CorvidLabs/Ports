import Testing
@testable import PortViewer

@Suite("PortInfo Edge Case Tests")
struct PortInfoEdgeCaseTests {

    // MARK: - Port 0 Behavior

    @Suite("Port Zero Behavior")
    struct PortZeroTests {

        @Test("Port 0 is privileged")
        func portZeroIsPrivileged() {
            let port = PortInfo(port: 0, transport: .tcp, processName: "test", pid: 1)
            #expect(port.isPrivileged == true)
        }

        @Test("Port 0 is not well-known")
        func portZeroNotWellKnown() {
            let port = PortInfo(port: 0, transport: .tcp, processName: "test", pid: 1)
            #expect(port.isWellKnown == false)
        }

        @Test("Port 0 with unknown process is other category")
        func portZeroCategory() {
            let port = PortInfo(port: 0, transport: .tcp, processName: "unknown_proc", pid: 1)
            #expect(port.category == .other)
        }
    }

    // MARK: - Very Long Process Names

    @Suite("Long Process Names")
    struct LongProcessNameTests {

        @Test("Very long process name is handled")
        func veryLongProcessName() {
            let longName = String(repeating: "a", count: 1000)
            let port = PortInfo(port: 3000, transport: .tcp, processName: longName, pid: 1234)
            #expect(port.processName.count == 1000)
            #expect(port.category == .other)
        }

        @Test("Process name with special characters")
        func specialCharacterProcessName() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "my-app_v2.0", pid: 1234)
            #expect(port.processName == "my-app_v2.0")
        }

        @Test("Empty-like process name")
        func emptyProcessName() {
            let port = PortInfo(port: 3000, transport: .tcp, processName: "", pid: 1234)
            #expect(port.processName == "")
            #expect(port.category == .other)
        }

        @Test("Process name containing category keyword in longer string")
        func containsKeyword() {
            // "node" is a dev process; "mynode_app" should still match because contains("node")
            let port = PortInfo(port: 9999, transport: .tcp, processName: "mynode_app", pid: 1234)
            #expect(port.category == .dev)
        }
    }

    // MARK: - IPv6 Address Handling

    @Suite("IPv6 Address Handling")
    struct IPv6Tests {

        @Test("IPv6 loopback [::1] is local only")
        func ipv6LoopbackIsLocal() {
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

        @Test("IPv6 wildcard [::] is exposed")
        func ipv6WildcardIsExposed() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "[::]:3000"
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
        }

        @Test("IPv6 specific address is exposed")
        func ipv6SpecificAddressIsExposed() {
            let port = PortInfo(
                port: 8080,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "[fe80::1]:8080"
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
        }

        @Test("IPv6 loopback in remote address")
        func ipv6RemoteAddress() {
            let port = PortInfo(
                port: 443,
                transport: .tcp,
                processName: "curl",
                pid: 1234,
                localAddress: "[::1]:54321",
                remoteAddress: "[::1]:443"
            )
            #expect(port.remoteAddress == "[::1]:443")
            #expect(port.isLocalOnly == true)
        }
    }

    // MARK: - Multiple Exposure Scenarios

    @Suite("Exposure Scenarios")
    struct ExposureScenarioTests {

        @Test("localhost string is local only")
        func localhostStringIsLocal() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "localhost:3000"
            )
            #expect(port.isLocalOnly == true)
        }

        @Test("Specific IP address is exposed")
        func specificIpIsExposed() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "192.168.1.100:3000"
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
        }

        @Test("Wildcard * is exposed")
        func wildcardIsExposed() {
            let port = PortInfo(
                port: 80,
                transport: .tcp,
                processName: "nginx",
                pid: 1234,
                localAddress: "*:80"
            )
            #expect(port.isExposed == true)
            #expect(port.exposureLabel == "*")
        }

        @Test("Empty local address is exposed")
        func emptyAddressIsExposed() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: ""
            )
            #expect(port.isLocalOnly == false)
            #expect(port.isExposed == true)
        }

        @Test("Address with 127.0.0.1 anywhere is local")
        func addressContaining127IsLocal() {
            let port = PortInfo(
                port: 3000,
                transport: .tcp,
                processName: "node",
                pid: 1234,
                localAddress: "127.0.0.1:3000"
            )
            #expect(port.isLocalOnly == true)
            #expect(port.exposureLabel == "127")
        }
    }

    // MARK: - UDP Port Category Detection

    @Suite("UDP Port Category Detection")
    struct UDPCategoryTests {

        @Test("UDP mDNSResponder is macos")
        func udpMdnsIsMacos() {
            let port = PortInfo(port: 5353, transport: .udp, processName: "mDNSResponder", pid: 1)
            #expect(port.category == .macos)
        }

        @Test("UDP on dev port is dev")
        func udpDevPort() {
            let port = PortInfo(port: 8080, transport: .udp, processName: "unknown", pid: 1)
            #expect(port.category == .dev)
        }

        @Test("UDP on database port is database")
        func udpDbPort() {
            let port = PortInfo(port: 3306, transport: .udp, processName: "unknown", pid: 1)
            #expect(port.category == .database)
        }

        @Test("UDP on gaming port is gaming")
        func udpGamingPort() {
            let port = PortInfo(port: 27015, transport: .udp, processName: "unknown", pid: 1)
            #expect(port.category == .gaming)
        }

        @Test("UDP media port 5353 is media")
        func udpMediaPort() {
            // 5353 is in mediaPorts; but mDNSResponder would be macOS, so use different process
            let port = PortInfo(port: 1900, transport: .udp, processName: "unknown_ssdp", pid: 1)
            #expect(port.category == .media)
        }
    }

    // MARK: - Well-Known Port Ranges

    @Suite("Well-Known Port Ranges")
    struct WellKnownRangeTests {

        @Test("FTP port 21 is well-known")
        func ftpIsWellKnown() {
            let port = PortInfo(port: 21, transport: .tcp, processName: "ftpd", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("Telnet port 23 is well-known")
        func telnetIsWellKnown() {
            let port = PortInfo(port: 23, transport: .tcp, processName: "telnetd", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("IMAP port 143 is well-known")
        func imapIsWellKnown() {
            let port = PortInfo(port: 143, transport: .tcp, processName: "dovecot", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("SMTPS port 465 is well-known")
        func smtpsIsWellKnown() {
            let port = PortInfo(port: 465, transport: .tcp, processName: "postfix", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("Submission port 587 is well-known")
        func submissionIsWellKnown() {
            let port = PortInfo(port: 587, transport: .tcp, processName: "postfix", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("IMAPS port 993 is well-known")
        func imapsIsWellKnown() {
            let port = PortInfo(port: 993, transport: .tcp, processName: "dovecot", pid: 1)
            #expect(port.isWellKnown == true)
        }

        @Test("Port 2000 is not well-known")
        func port2000NotWellKnown() {
            let port = PortInfo(port: 2000, transport: .tcp, processName: "app", pid: 1)
            #expect(port.isWellKnown == false)
        }

        @Test("Port 9999 is not well-known")
        func port9999NotWellKnown() {
            let port = PortInfo(port: 9999, transport: .tcp, processName: "app", pid: 1)
            #expect(port.isWellKnown == false)
        }
    }

    // MARK: - State Enum Comprehensive Tests

    @Suite("All TCP State Values")
    struct AllStateTests {

        @Test("LISTEN state")
        func listenState() {
            let state = PortInfo.State(rawValue: "LISTEN")
            #expect(state == .listen)
            #expect(state.rawValue == "LISTEN")
        }

        @Test("ESTABLISHED state")
        func establishedState() {
            let state = PortInfo.State(rawValue: "ESTABLISHED")
            #expect(state == .established)
            #expect(state.rawValue == "ESTABLISHED")
        }

        @Test("CLOSE_WAIT state")
        func closeWaitState() {
            let state = PortInfo.State(rawValue: "CLOSE_WAIT")
            #expect(state == .closeWait)
            #expect(state.rawValue == "CLOSE_WAIT")
        }

        @Test("TIME_WAIT state")
        func timeWaitState() {
            let state = PortInfo.State(rawValue: "TIME_WAIT")
            #expect(state == .timeWait)
            #expect(state.rawValue == "TIME_WAIT")
        }

        @Test("LAST_ACK state")
        func lastAckState() {
            let state = PortInfo.State(rawValue: "LAST_ACK")
            #expect(state == .lastAck)
            #expect(state.rawValue == "LAST_ACK")
        }

        @Test("FIN_WAIT_1 state")
        func finWait1State() {
            let state = PortInfo.State(rawValue: "FIN_WAIT_1")
            #expect(state == .finWait1)
            #expect(state.rawValue == "FIN_WAIT_1")
        }

        @Test("FIN_WAIT_2 state")
        func finWait2State() {
            let state = PortInfo.State(rawValue: "FIN_WAIT_2")
            #expect(state == .finWait2)
            #expect(state.rawValue == "FIN_WAIT_2")
        }

        @Test("SYN_SENT state")
        func synSentState() {
            let state = PortInfo.State(rawValue: "SYN_SENT")
            #expect(state == .synSent)
            #expect(state.rawValue == "SYN_SENT")
        }

        @Test("SYN_RECEIVED state")
        func synReceivedState() {
            let state = PortInfo.State(rawValue: "SYN_RECEIVED")
            #expect(state == .synReceived)
            #expect(state.rawValue == "SYN_RECEIVED")
        }

        @Test("CLOSING state")
        func closingState() {
            let state = PortInfo.State(rawValue: "CLOSING")
            #expect(state == .closing)
            #expect(state.rawValue == "CLOSING")
        }

        @Test("CLOSED state")
        func closedState() {
            let state = PortInfo.State(rawValue: "CLOSED")
            #expect(state == .closed)
            #expect(state.rawValue == "CLOSED")
        }

        @Test("Unknown state from invalid string")
        func unknownFromInvalid() {
            let state = PortInfo.State(rawValue: "BOGUS_STATE")
            #expect(state == .unknown)
        }

        @Test("Case insensitive state parsing for all states")
        func caseInsensitiveAll() {
            #expect(PortInfo.State(rawValue: "listen") == .listen)
            #expect(PortInfo.State(rawValue: "established") == .established)
            #expect(PortInfo.State(rawValue: "close_wait") == .closeWait)
            #expect(PortInfo.State(rawValue: "time_wait") == .timeWait)
            #expect(PortInfo.State(rawValue: "last_ack") == .lastAck)
            #expect(PortInfo.State(rawValue: "fin_wait_1") == .finWait1)
            #expect(PortInfo.State(rawValue: "fin_wait_2") == .finWait2)
            #expect(PortInfo.State(rawValue: "syn_sent") == .synSent)
            #expect(PortInfo.State(rawValue: "syn_received") == .synReceived)
            #expect(PortInfo.State(rawValue: "closing") == .closing)
            #expect(PortInfo.State(rawValue: "closed") == .closed)
        }

        @Test("State displayName replaces underscores with spaces")
        func displayNameFormatting() {
            #expect(PortInfo.State.closeWait.displayName == "CLOSE WAIT")
            #expect(PortInfo.State.timeWait.displayName == "TIME WAIT")
            #expect(PortInfo.State.finWait1.displayName == "FIN WAIT 1")
            #expect(PortInfo.State.finWait2.displayName == "FIN WAIT 2")
            #expect(PortInfo.State.lastAck.displayName == "LAST ACK")
            #expect(PortInfo.State.synSent.displayName == "SYN SENT")
            #expect(PortInfo.State.synReceived.displayName == "SYN RECEIVED")
            #expect(PortInfo.State.listen.displayName == "LISTEN")
            #expect(PortInfo.State.established.displayName == "ESTABLISHED")
            #expect(PortInfo.State.closing.displayName == "CLOSING")
            #expect(PortInfo.State.closed.displayName == "CLOSED")
        }

        @Test("Empty string maps to unknown state")
        func emptyStringIsUnknown() {
            let state = PortInfo.State(rawValue: "")
            #expect(state == .unknown)
        }
    }

    // MARK: - Sort Order Tests

    @Suite("Sort Order Values")
    struct SortOrderTests {

        @Test("PortSortOrder has all expected cases")
        func allSortOrderCases() {
            let cases = PortSortOrder.allCases
            #expect(cases.count == 5)
        }

        @Test("PortSortOrder raw values are correct")
        func sortOrderRawValues() {
            #expect(PortSortOrder.port.rawValue == "Port")
            #expect(PortSortOrder.process.rawValue == "Process")
            #expect(PortSortOrder.pid.rawValue == "PID")
            #expect(PortSortOrder.state.rawValue == "State")
            #expect(PortSortOrder.transport.rawValue == "Protocol")
        }

        @Test("Category sort order values are sequential")
        func categorySortOrderSequential() {
            #expect(PortInfo.Category.dev.sortOrder == 0)
            #expect(PortInfo.Category.web.sortOrder == 1)
            #expect(PortInfo.Category.database.sortOrder == 2)
            #expect(PortInfo.Category.media.sortOrder == 3)
            #expect(PortInfo.Category.gaming.sortOrder == 4)
            #expect(PortInfo.Category.comms.sortOrder == 5)
            #expect(PortInfo.Category.macos.sortOrder == 6)
            #expect(PortInfo.Category.other.sortOrder == 7)
        }

        @Test("All categories have unique sort orders")
        func uniqueSortOrders() {
            let sortOrders = PortInfo.Category.allCases.map { $0.sortOrder }
            let uniqueOrders = Set(sortOrders)
            #expect(sortOrders.count == uniqueOrders.count)
        }
    }

    // MARK: - Category Properties

    @Suite("Category Properties")
    struct CategoryPropertyTests {

        @Test("All categories have non-empty labels")
        func allCategoriesHaveLabels() {
            for category in PortInfo.Category.allCases {
                #expect(category.label.isEmpty == false, "\(category) should have a label")
            }
        }

        @Test("All categories have non-empty icons")
        func allCategoriesHaveIcons() {
            for category in PortInfo.Category.allCases {
                #expect(category.icon.isEmpty == false, "\(category) should have an icon")
            }
        }

        @Test("Database label is 'data' not 'database'")
        func databaseLabelIsShort() {
            #expect(PortInfo.Category.database.label == "data")
        }

        @Test("Category allCases contains all 8 categories")
        func allCasesComplete() {
            #expect(PortInfo.Category.allCases.count == 8)
        }
    }

    // MARK: - Risk Properties

    @Suite("Risk Properties")
    struct RiskPropertyTests {

        @Test("All risk levels have non-empty icons")
        func allRiskLevelsHaveIcons() {
            let risks: [PortInfo.Risk] = [.safe, .normal, .attention, .unknown]
            for risk in risks {
                #expect(risk.icon.isEmpty == false, "\(risk) should have an icon")
            }
        }

        @Test("Risk icon names follow expected pattern")
        func riskIconPattern() {
            #expect(PortInfo.Risk.safe.icon.contains("shield"))
            #expect(PortInfo.Risk.normal.icon.contains("shield"))
            #expect(PortInfo.Risk.attention.icon.contains("shield"))
            #expect(PortInfo.Risk.unknown.icon.contains("shield"))
        }
    }

    // MARK: - Transport Properties

    @Suite("Transport Properties")
    struct TransportPropertyTests {

        @Test("Transport allCases contains TCP and UDP")
        func allTransports() {
            let transports = PortInfo.Transport.allCases
            #expect(transports.count == 2)
            #expect(transports.contains(.tcp))
            #expect(transports.contains(.udp))
        }

        @Test("TCP raw value is uppercase")
        func tcpRawValue() {
            #expect(PortInfo.Transport.tcp.rawValue == "TCP")
        }

        @Test("UDP raw value is uppercase")
        func udpRawValue() {
            #expect(PortInfo.Transport.udp.rawValue == "UDP")
        }
    }

    // MARK: - Hashable Conformance

    @Suite("Hashable Conformance")
    struct HashableTests {

        @Test("PortInfo with same ID hashes equally")
        func sameIdHashesEqual() {
            let id = Foundation.UUID()
            let port1 = PortInfo(id: id, port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let port2 = PortInfo(id: id, port: 3000, transport: .tcp, processName: "node", pid: 1234)
            #expect(port1 == port2)
        }

        @Test("PortInfo can be stored in a Set")
        func canStoreInSet() {
            let id = Foundation.UUID()
            let port1 = PortInfo(id: id, port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let port2 = PortInfo(id: id, port: 3000, transport: .tcp, processName: "node", pid: 1234)
            let set: Set<PortInfo> = [port1, port2]
            #expect(set.count == 1)
        }
    }
}
