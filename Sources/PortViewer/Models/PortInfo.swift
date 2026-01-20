import Foundation

/// Represents information about an open network port.
public struct PortInfo: Identifiable, Sendable, Hashable {

    // MARK: - Types

    public enum Transport: String, Sendable, CaseIterable {
        case tcp = "TCP"
        case udp = "UDP"
    }

    public enum Category: String, Sendable, CaseIterable {
        case macos = "macos"
        case dev = "dev"
        case database = "database"
        case web = "web"
        case gaming = "gaming"
        case media = "media"
        case comms = "comms"
        case other = "other"

        public var label: String {
            switch self {
            case .macos: return "macos"
            case .dev: return "dev"
            case .database: return "data"
            case .web: return "web"
            case .gaming: return "gaming"
            case .media: return "media"
            case .comms: return "comms"
            case .other: return "other"
            }
        }

        public var icon: String {
            switch self {
            case .macos: return "apple.logo"
            case .dev: return "hammer.fill"
            case .database: return "cylinder.fill"
            case .web: return "globe"
            case .gaming: return "gamecontroller.fill"
            case .media: return "play.circle.fill"
            case .comms: return "message.fill"
            case .other: return "questionmark.circle"
            }
        }

        public var sortOrder: Int {
            switch self {
            case .dev: return 0
            case .web: return 1
            case .database: return 2
            case .media: return 3
            case .gaming: return 4
            case .comms: return 5
            case .macos: return 6
            case .other: return 7
            }
        }
    }

    public enum Risk: String, Sendable {
        case safe = "safe"          // Known system service, localhost only
        case normal = "normal"      // Expected for category, known process
        case attention = "attention" // Exposed externally, unusual port
        case unknown = "unknown"    // Unknown process or unusual behavior

        public var icon: String {
            switch self {
            case .safe: return "checkmark.shield.fill"
            case .normal: return "shield.fill"
            case .attention: return "exclamationmark.shield.fill"
            case .unknown: return "questionmark.shield.fill"
            }
        }
    }

    public enum State: String, Sendable {
        case listen = "LISTEN"
        case established = "ESTABLISHED"
        case closeWait = "CLOSE_WAIT"
        case timeWait = "TIME_WAIT"
        case closed = "CLOSED"
        case synSent = "SYN_SENT"
        case synReceived = "SYN_RECEIVED"
        case finWait1 = "FIN_WAIT_1"
        case finWait2 = "FIN_WAIT_2"
        case lastAck = "LAST_ACK"
        case closing = "CLOSING"
        case unknown

        public init(rawValue: String) {
            switch rawValue.uppercased() {
            case "LISTEN": self = .listen
            case "ESTABLISHED": self = .established
            case "CLOSE_WAIT": self = .closeWait
            case "TIME_WAIT": self = .timeWait
            case "CLOSED": self = .closed
            case "SYN_SENT": self = .synSent
            case "SYN_RECEIVED": self = .synReceived
            case "FIN_WAIT_1": self = .finWait1
            case "FIN_WAIT_2": self = .finWait2
            case "LAST_ACK": self = .lastAck
            case "CLOSING": self = .closing
            default: self = .unknown
            }
        }

        public var displayName: String {
            rawValue.replacingOccurrences(of: "_", with: " ")
        }
    }

    // MARK: - Properties

    public let id: UUID
    public let port: Int
    public let transport: Transport
    public let processName: String
    public let pid: Int
    public let user: String
    public let localAddress: String
    public let remoteAddress: String?
    public let state: State?

    // MARK: - Initializers

    public init(
        id: UUID = UUID(),
        port: Int,
        transport: Transport,
        processName: String,
        pid: Int,
        user: String = "",
        localAddress: String = "",
        remoteAddress: String? = nil,
        state: State? = nil
    ) {
        self.id = id
        self.port = port
        self.transport = transport
        self.processName = processName
        self.pid = pid
        self.user = user
        self.localAddress = localAddress
        self.remoteAddress = remoteAddress
        self.state = state
    }

    // MARK: - Computed Properties

    public var category: Category {
        let proc = processName.lowercased()

        // macOS system services (expected, can usually ignore)
        let macosProcesses = [
            "rapportd", "sharingd", "airplayd", "airplayxpc", "controlce",
            "identityservicesd", "imaged", "symptomsd", "configd", "mDNSResponder",
            "UserEventAgent", "launchd", "loginwindow", "WindowServer",
            "coreservicesd", "cfprefsd", "distnoted", "trustd", "secd",
            "locationd", "bluetoothd", "wirelessproxd", "wifip2pd",
            "audioaccessory", "coreaudiod", "remotepairing", "remindd",
            "screensharing", "screencapturekit", "findmydeviced", "cloudd",
            "apsd", "parsecd", "syncdefaultsd", "mdnsresponder"
        ]
        if macosProcesses.contains(where: { proc.contains($0.lowercased()) }) {
            return .macos
        }

        // Development tools
        let devProcesses = [
            "node", "bun", "deno", "python", "ruby", "java", "go", "cargo", "rustc",
            "swift", "xcode", "lldb", "webpack", "vite", "esbuild", "rollup",
            "npm", "yarn", "pnpm", "tsx", "ts-node", "nodemon", "pm2",
            "flask", "django", "rails", "spring", "gradle", "maven",
            "php", "artisan", "composer", "laravel",
            "flutter", "dart", "android", "adb", "emulator",
            "docker", "containerd", "kubectl", "minikube",
            "code", "cursor", "zed", "sublime", "atom", "vim", "nvim",
            "jupyter", "ipython", "pytest", "jest", "mocha",
            "git", "gh", "hub"
        ]
        let devPorts = [3000, 3001, 4200, 5173, 5174, 8080, 8081, 8888, 9229, 35729, 24678, 4000, 5000, 8000]
        if devProcesses.contains(where: { proc.contains($0) }) || devPorts.contains(port) {
            return .dev
        }

        // Databases
        let dbProcesses = [
            "mysql", "mariadb", "postgres", "postgresql", "psql",
            "mongo", "mongod", "redis", "memcached",
            "elasticsearch", "opensearch", "solr",
            "cassandra", "couchdb", "couchbase",
            "neo4j", "arangodb", "dgraph",
            "influxdb", "timescaledb", "clickhouse",
            "sqlite", "sqlcipher"
        ]
        let dbPorts = [3306, 5432, 27017, 6379, 11211, 9200, 9300, 7474, 8529, 5984, 1433, 1521]
        if dbProcesses.contains(where: { proc.contains($0) }) || dbPorts.contains(port) {
            return .database
        }

        // Web servers
        let webProcesses = [
            "nginx", "apache", "httpd", "caddy", "traefik", "haproxy",
            "lighttpd", "openresty", "tengine"
        ]
        let webPorts = [80, 443, 8443]
        if webProcesses.contains(where: { proc.contains($0) }) || webPorts.contains(port) {
            return .web
        }

        // Gaming
        let gamingProcesses = [
            "steam", "steamwebhelper", "epicgames", "epic",
            "minecraft", "java", // minecraft uses java
            "discord", // often gaming related
            "battlenet", "origin", "uplay", "gog",
            "unity", "unreal", "godot"
        ]
        let gamingPorts = [27015, 27016, 25565, 19132, 7777, 7778] // common game server ports
        if gamingProcesses.contains(where: { proc.contains($0) }) || gamingPorts.contains(port) {
            return .gaming
        }

        // Media & streaming
        let mediaProcesses = [
            "plex", "plexmedia", "emby", "jellyfin",
            "spotify", "music", "itunes", "apple music",
            "vlc", "mpv", "ffmpeg", "obs", "streamlabs",
            "handbrake", "kodi", "infuse",
            "airplay", "homekit", "homepod"
        ]
        let mediaPorts = [32400, 8096, 8920, 1900, 5353] // plex, emby, dlna
        if mediaProcesses.contains(where: { proc.contains($0) }) || mediaPorts.contains(port) {
            return .media
        }

        // Communication
        let commsProcesses = [
            "slack", "teams", "zoom", "webex",
            "telegram", "signal", "whatsapp", "messenger",
            "skype", "facetime", "messages",
            "mail", "thunderbird", "outlook",
            "ssh", "sshd", "mosh"
        ]
        let commsPorts = [22, 993, 587, 465, 143, 110, 25] // ssh, email
        if commsProcesses.contains(where: { proc.contains($0) }) || commsPorts.contains(port) {
            return .comms
        }

        return .other
    }

    /// Risk assessment based on process, port, and exposure
    public var risk: Risk {
        // Known safe macOS services on localhost
        if category == .macos && isLocalOnly {
            return .safe
        }

        // Known categories with recognized processes
        if category != .other {
            if isLocalOnly {
                return .safe
            }
            return .normal
        }

        // Unknown process exposed externally
        if !isLocalOnly {
            return .attention
        }

        return .unknown
    }

    /// Whether the port is only listening on localhost
    public var isLocalOnly: Bool {
        let addr = localAddress.lowercased()
        return addr.contains("127.0.0.1") ||
               addr.contains("localhost") ||
               addr.contains("[::1]") ||
               addr.hasPrefix("localhost:")
    }

    /// Whether the port is exposed to the network
    public var isExposed: Bool {
        !isLocalOnly
    }

    /// Human-readable exposure description
    public var exposureLabel: String {
        if isLocalOnly {
            return "local"
        } else if localAddress.contains("*") || localAddress.contains("0.0.0.0") {
            return "all interfaces"
        } else {
            return "network"
        }
    }

    /// Whether this is a privileged port (requires root)
    public var isPrivileged: Bool {
        port < 1024
    }

    /// Whether this is a well-known port
    public var isWellKnown: Bool {
        let wellKnownPorts: Set<Int> = [
            20, 21, 22, 23, 25, 53, 67, 68, 80, 110, 119, 123, 143,
            161, 194, 443, 465, 514, 587, 993, 995,
            3306, 5432, 6379, 27017, // databases
            3000, 4000, 5000, 8000, 8080 // common dev
        ]
        return wellKnownPorts.contains(port)
    }
}

// MARK: - Sorting

public enum PortSortOrder: String, CaseIterable, Sendable {
    case port = "Port"
    case process = "Process"
    case pid = "PID"
    case state = "State"
    case transport = "Protocol"
}
