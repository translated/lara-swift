import Foundation

/// Generic helper that performs polling until a condition is met.
public enum Poller {

    /// Starts a polling loop.
    /// - Parameters:
    ///   - initial: Initial value (may already satisfy `isFinished`).
    ///   - interval: Polling cadence in seconds (default: 2).
    ///   - maxTime: Overall timeout in seconds. `0` disables the timeout.
    ///   - next: Closure that retrieves the next value.
    ///   - isFinished: Predicate that returns `true` when polling should stop.
    ///   - progress: Optional per-tick callback.
    /// - Returns: The final value when polling completes.
    public static func poll<Value>(
        initial value: Value,
        interval: TimeInterval = 2.0,
        maxTime: TimeInterval = 0,
        next: (Value) async throws -> Value,
        isFinished: (Value) -> Bool,
        progress: ((Value) -> Void)? = nil
    ) async throws -> Value {
        var current = value
        let startTime = Date()

        if isFinished(current) {
            return current
        }

        while true {
            if maxTime > 0 && Date().timeIntervalSince(startTime) >= maxTime {
                throw TimeoutError("Operation timed out after \(Int(maxTime)) seconds")
            }

            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            current = try await next(current)
            progress?(current)

            if isFinished(current) {
                return current
            }
        }
    }
}