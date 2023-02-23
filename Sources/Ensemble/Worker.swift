import Foundation

// MARK: - `Worker` -

/// A Worker manages asynchronous work and is parameterized over a Reducer and a result type `T`.
/// Use a Worker to define a unit of work that can be executed asynchronously,
/// and provides support for prioritization and error handling
public struct Worker<Reducer: Reducing, T>: Sendable {
    enum Operation {
        
        /// No operation is currently being performed.
        case none
        
        /// The `Worker` is executing a task with the given `priority`, it's also passed "work",
        /// represented as a closure that returns a result of type `T`.
        /// An optional error handler can be specified to handle any errors that may occur.
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
    /// - Parameter id: A unique ID representing this work, this default may be overriden
    /// - Parameter operation: The operation the worker will perform.
    init(
        id: String = UUID().uuidString,
        operation: Operation
    ) {
        self.id = id
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
