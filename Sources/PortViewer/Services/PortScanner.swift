@preconcurrency import Foundation

/// Actor responsible for scanning open network ports using lsof.
public actor PortScanner {

    // MARK: - Types

    public enum ScanError: Error, LocalizedError, Sendable {
        case processExecutionFailed(String)
        case parsingFailed(String)

        public var errorDescription: String? {
            switch self {
            case .processExecutionFailed(let message):
                return "Failed to execute lsof: \(message)"
            case .parsingFailed(let message):
                return "Failed to parse output: \(message)"
            }
        }
    }

    // MARK: - Initializers

    public init() {}

    // MARK: - Public Methods

    /// Scans for open network ports and returns port information.
    public func scan() async throws -> [PortInfo] {
        let output = try await runLsof()
        return parseLsofOutput(output)
    }

    // MARK: - Private Methods

    private func runLsof() async throws -> String {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-i", "-P", "-n"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            throw ScanError.processExecutionFailed(error.localizedDescription)
        }

        return await withCheckedContinuation { continuation in
            process.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                continuation.resume(returning: output)
            }
        }
    }

    private func parseLsofOutput(_ output: String) -> [PortInfo] {
        var ports: [PortInfo] = []
        var seenPorts: Set<String> = []
        let lines = output.components(separatedBy: "\n")

        for line in lines.dropFirst() {
            guard let portInfo = parseLineToPortInfo(line) else {
                continue
            }

            let uniqueKey = "\(portInfo.port)-\(portInfo.transport.rawValue)-\(portInfo.pid)"
            guard !seenPorts.contains(uniqueKey) else {
                continue
            }
            seenPorts.insert(uniqueKey)
            ports.append(portInfo)
        }

        return ports.sorted { $0.port < $1.port }
    }

    private func parseLineToPortInfo(_ line: String) -> PortInfo? {
        let components = line.split(separator: " ", omittingEmptySubsequences: true)

        guard components.count >= 9 else {
            return nil
        }

        let command = String(components[0])
        guard let pid = Int(components[1]) else {
            return nil
        }

        let user = String(components[2])

        let nodeType = String(components[7])
        guard let transport = parseTransport(nodeType) else {
            return nil
        }

        let nameField = components[8...].joined(separator: " ")
        let (port, localAddress, remoteAddress, state) = parseNameField(nameField)

        guard let port = port else {
            return nil
        }

        return PortInfo(
            port: port,
            transport: transport,
            processName: command,
            pid: pid,
            user: user,
            localAddress: localAddress,
            remoteAddress: remoteAddress,
            state: state
        )
    }

    private func parseTransport(_ value: String) -> PortInfo.Transport? {
        switch value.uppercased() {
        case "TCP":
            return .tcp
        case "UDP":
            return .udp
        default:
            return nil
        }
    }

    private func parseNameField(_ name: String) -> (Int?, String, String?, PortInfo.State?) {
        var state: PortInfo.State?
        var localAddress = ""
        var remoteAddress: String?

        let parts = name.components(separatedBy: " ")
        var addressPart = parts[0]

        if parts.count > 1 {
            let statePart = parts.last ?? ""
            if statePart.hasPrefix("(") && statePart.hasSuffix(")") {
                let stateString = String(statePart.dropFirst().dropLast())
                state = PortInfo.State(rawValue: stateString)
            }
        }

        if addressPart.contains("->") {
            let connectionParts = addressPart.components(separatedBy: "->")
            if connectionParts.count == 2 {
                localAddress = connectionParts[0]
                remoteAddress = connectionParts[1]
                addressPart = connectionParts[0]
            }
        } else {
            localAddress = addressPart
        }

        if let colonIndex = addressPart.lastIndex(of: ":") {
            let portString = String(addressPart[addressPart.index(after: colonIndex)...])
            if let port = Int(portString) {
                return (port, localAddress, remoteAddress, state)
            }
        }

        return (nil, localAddress, remoteAddress, state)
    }
}
