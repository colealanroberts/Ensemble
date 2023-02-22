import Foundation

// MARK: - `Worker` -

/// A box type for managing asynchronous work.
public struct Worker<Reducer: Reducing, T>: Sendable {
    enum Operation {
        case none
        
        case task(
            priority: TaskPriority,
            operation: () async throws -> T,
            error: ((any Error) -> Reducer.Action)?
        )
    }
    
    /// A unique identifier for the worker instance.
    let id: String
    
    /// The operation the worker is performing.
    let operation: Operation
    
    // MARK: - `Init` -
    
    /// Initializes a new worker with the given operation.
    ///
    /// - Parameter operation: The operation the worker will perform.
    init(operation: Operation) {
        self.id = UUID().uuidString
        self.operation = operation
    }
}

// MARK: - `Worker+Utility` -

extension Worker {
    
    /// A Worker instance that performs no operation.
    public static var none: Self {
        Self(operation: .none)
    }
    
    /// Creates a Worker instance with the given operation.
    /// - Parameter priority: The `TaskPriority` of the operation, defaulting to `.medium`
    /// - Parameter operation: The asynchronous operation the worker will perform.
    /// - Parameter error: The error, if any, and `Action` to perform
    /// - Returns: A new `Worker` instance that performs the given operation.
    public static func task(
        priority: TaskPriority = .medium,
        _ operation: @escaping () async throws -> T,
        error: ((any Error) -> Reducer.Action)? = nil
    ) -> Self {
        Self(operation: .task(priority: priority, operation: operation, error: error))
    }
}
