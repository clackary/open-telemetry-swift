
#if os(Linux)

import Foundation

public extension OpenTelemetry {
    @TaskLocal
    static var activeSpan: Span? = nil

    @_unsafeInheritExecutor
    @discardableResult
    static func withValueAsync<T>(_ value: Span?, operation: () async throws -> T) async rethrows -> T {
        try await OpenTelemetry.$activeSpan.withValue(value, operation: operation)
    }

    @discardableResult
    static func withValue<T>(_ value: Span?, operation: @escaping () throws -> T) rethrows -> T {
        try OpenTelemetry.$activeSpan.withValue(value, operation: operation)
    }

    static func getActiveSpan() -> Span? {
        return activeSpan
    }
}

#endif
