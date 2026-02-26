import Testing
@testable import PortViewer

@Suite("ProcessKiller Tests")
struct ProcessKillerTests {

    // MARK: - KillError Description Tests

    @Suite("KillError Descriptions")
    struct KillErrorDescriptionTests {

        @Test("processNotFound contains PID")
        func processNotFoundDescription() {
            let error = ProcessKiller.KillError.processNotFound(pid: 12345)
            #expect(error.errorDescription?.contains("12345") == true)
            #expect(error.errorDescription?.contains("not found") == true)
        }

        @Test("permissionDenied contains process name and PID")
        func permissionDeniedDescription() {
            let error = ProcessKiller.KillError.permissionDenied(pid: 999, processName: "nginx")
            #expect(error.errorDescription?.contains("nginx") == true)
            #expect(error.errorDescription?.contains("999") == true)
            #expect(error.errorDescription?.contains("Permission denied") == true)
        }

        @Test("permissionDenied suggests administrator")
        func permissionDeniedSuggestsAdmin() {
            let error = ProcessKiller.KillError.permissionDenied(pid: 1, processName: "launchd")
            #expect(error.errorDescription?.contains("administrator") == true)
        }

        @Test("failed contains PID and message")
        func failedDescription() {
            let error = ProcessKiller.KillError.failed(pid: 5678, message: "signal error")
            #expect(error.errorDescription?.contains("5678") == true)
            #expect(error.errorDescription?.contains("signal error") == true)
        }

        @Test("failed with empty message")
        func failedEmptyMessage() {
            let error = ProcessKiller.KillError.failed(pid: 100, message: "")
            #expect(error.errorDescription?.contains("100") == true)
        }
    }

    // MARK: - KillSignal Tests

    @Suite("KillSignal Values")
    struct KillSignalTests {

        @Test("terminate signal is SIGTERM (15)")
        func terminateSignal() {
            let signal = ProcessKiller.KillSignal.terminate
            #expect(signal.rawValue == 15)
        }

        @Test("kill signal is SIGKILL (9)")
        func killSignal() {
            let signal = ProcessKiller.KillSignal.kill
            #expect(signal.rawValue == 9)
        }
    }

    // MARK: - KillError Equatable-Like Tests

    @Suite("KillError Differentiation")
    struct KillErrorDifferentiationTests {

        @Test("Different error types have different descriptions")
        func differentErrorTypes() {
            let notFound = ProcessKiller.KillError.processNotFound(pid: 1)
            let denied = ProcessKiller.KillError.permissionDenied(pid: 1, processName: "test")
            let failed = ProcessKiller.KillError.failed(pid: 1, message: "error")

            #expect(notFound.errorDescription != denied.errorDescription)
            #expect(denied.errorDescription != failed.errorDescription)
            #expect(notFound.errorDescription != failed.errorDescription)
        }

        @Test("Same error type with different PIDs have different descriptions")
        func differentPids() {
            let error1 = ProcessKiller.KillError.processNotFound(pid: 100)
            let error2 = ProcessKiller.KillError.processNotFound(pid: 200)
            #expect(error1.errorDescription != error2.errorDescription)
        }

        @Test("permissionDenied with different process names have different descriptions")
        func differentProcessNames() {
            let error1 = ProcessKiller.KillError.permissionDenied(pid: 1, processName: "nginx")
            let error2 = ProcessKiller.KillError.permissionDenied(pid: 1, processName: "postgres")
            #expect(error1.errorDescription != error2.errorDescription)
        }
    }

    // MARK: - KillError Conforms to Error

    @Suite("KillError Protocol Conformance")
    struct KillErrorConformanceTests {

        @Test("KillError conforms to Error and LocalizedError")
        func conformsToError() {
            let error: any Error = ProcessKiller.KillError.processNotFound(pid: 1)
            #expect(error.localizedDescription.isEmpty == false)
        }

        @Test("KillError localizedDescription matches errorDescription")
        func localizedMatchesError() {
            let error = ProcessKiller.KillError.failed(pid: 42, message: "something went wrong")
            #expect(error.localizedDescription == error.errorDescription)
        }
    }
}
