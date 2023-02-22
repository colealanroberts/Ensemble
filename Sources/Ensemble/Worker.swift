import Foundation

// MARK: - `Worker` -

/// A box type for managing asynchronous work.
public struct Worker<T> {
    
    enum Operation {
        case none
        case task(() async -> T)
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
    
    /// A worker instance that performs no operation.
    public static var none: Self {
        Self(operation: .none)
    }
    
    /// Creates a worker instance with the given operation.
    ///
    /// - Parameter operation: The asynchronous operation the worker will perform.
    /// - Returns: A new `Worker` instance that performs the given operation.
    public static func task(operation: @escaping () async -> T) -> Self {
        Self(operation: .task(operation))
    }
}
