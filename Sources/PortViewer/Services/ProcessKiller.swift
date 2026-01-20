@preconcurrency import Foundation

/// Actor responsible for terminating processes.
public actor ProcessKiller {

    // MARK: - Types

    public enum KillError: Error, LocalizedError, Sendable {
        case processNotFound(pid: Int)
        case permissionDenied(pid: Int, processName: String)
        case failed(pid: Int, message: String)

        public var errorDescription: String? {
            switch self {
            case .processNotFound(let pid):
                return "Process \(pid) not found"
            case .permissionDenied(let pid, let processName):
                return "Permission denied to kill \(processName) (PID: \(pid)). Try running as administrator."
            case .failed(let pid, let message):
                return "Failed to kill process \(pid): \(message)"
            }
        }
    }

    public enum KillSignal: Int32, Sendable {
        case terminate = 15  // SIGTERM - graceful
        case kill = 9        // SIGKILL - force
    }

    // MARK: - Initializers

    public init() {}

    // MARK: - Public Methods

    /// Kills a process with the specified PID.
    /// - Parameters:
    ///   - pid: The process ID to kill
    ///   - signal: The signal to send (default: SIGTERM)
    ///   - processName: Optional process name for error messages
    public func kill(pid: Int, signal: KillSignal = .terminate, processName: String = "") async throws {
        let process = Process()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/kill")
        process.arguments = ["-\(signal.rawValue)", String(pid)]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw KillError.failed(pid: pid, message: error.localizedDescription)
        }

        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { terminatedProcess in
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                if terminatedProcess.terminationStatus == 0 {
                    continuation.resume()
                } else if errorOutput.lowercased().contains("no such process") {
                    continuation.resume(throwing: KillError.processNotFound(pid: pid))
                } else if errorOutput.lowercased().contains("permission denied") ||
                          errorOutput.lowercased().contains("operation not permitted") {
                    continuation.resume(throwing: KillError.permissionDenied(pid: pid, processName: processName))
                } else {
                    continuation.resume(throwing: KillError.failed(pid: pid, message: errorOutput))
                }
            }
        }
    }

    /// Force kills a process (SIGKILL).
    public func forceKill(pid: Int, processName: String = "") async throws {
        try await kill(pid: pid, signal: .kill, processName: processName)
    }
}
