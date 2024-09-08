import Foundation

// MARK: - Worker

/// A Worker manages asynchronous work and provides support for task prioritization and error handling.
public struct Worker<T>: Sendable {

    /// A unique identifier for the worker instance.
    let uuid: UUID

    /// The operation the worker is performing.
    let operation: Operation
    
    // MARK: Init
    
    /// Initializes a new worker with the given operation.
    /// - Parameter operation: The operation the worker will perform.
    private init(
        uuid: UUID = .init(),
        operation: Operation
    ) {
        self.uuid = uuid
        self.operation = operation
    }
}

// MARK: - Worker+Operation

extension Worker {
    enum Operation {
        /// No operation is currently being performed.
        case none
        
        /// The `Worker` is executing a task with the given `priority`, it's also passed "work",
        /// represented as a closure that returns a result of type `T`.
        /// An optional error handler can be specified to handle any errors that may occur.
        /// - Parameter priority: The priority level of the task.
        /// - Parameter operation: The operation the worker will perform.
        /// - Parameter error: A closure to perform, returning `T`.
        case task(
            priority: TaskPriority,
            operation: () async throws -> T,
            error: ((any Error) -> T)?
        )
        
        /// Represents a stream of events that can be produced by a worker.
        /// - Parameter priority: The priority level of the stream.
        /// - Parameter operation: An asynchronous closure that takes a `Stream<T>` object
        /// and produces events through it.
        case stream(
            priority: TaskPriority,
            operation: (Stream<T>) async -> Void
        )
    }
}

// MARK: - Worker+Utility

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
        error: ((any Error) -> T)? = nil
    ) -> Self {
        Self(
            operation: .task(
                priority: priority,
                operation: operation,
                error: error
            )
        )
    }

    /// Creates a new worker instance that produces a stream of events using the provided closure.
    /// - Parameter id: A unique ID representing this work, this default may be overriden.
    /// - Parameter priority: The `TaskPriority` of the operation, defaulting to `.medium`
    /// - Parameter stream: An asynchronous closure that takes a `Stream<T>` object and produces events through it.
    /// - Returns: A new worker instance with a `stream` operation.
    public static func stream(
        uuid: UUID,
        priority: TaskPriority = .medium,
        _ stream: @escaping (Stream<T>) async -> Void
    ) -> Self {
        Self(
            uuid: uuid,
            operation: .stream(
                priority: priority,
                operation: stream
            )
        )
    }
}

// MARK: - Worker+Stream<U>

/// An extension for the `Worker` class that provides a generic `Stream` type for sending asynchronous events.
public extension Worker {
    
    /// A generic struct that provides a simple way to produce and send asynchronous events to an `AsyncStream<U>`.
    struct Stream<U> {
        /// The `AsyncStream<U>.Continuation` object.
        let continuation: AsyncStream<U>.Continuation

        /// Initializes an instance of `Worker.Stream`.
        /// - Parameter continuation: The `AsyncStream<T>.Continuation` object.
        init(_ continuation: AsyncStream<U>.Continuation) {
            self.continuation = continuation
        }
        
        /// Sends an action to the `AsyncStream<U>.Continuation`.
        /// - Parameter action: The action to be sent.
        public func send(_ action: U) {
            continuation.yield(action)
        }
        
        /// Finishes the `AsyncStream<U>.Continuation`.
        public func finish() {
            continuation.finish()
        }
        
        /// Marks `Stream` as a callable function and exists solely as syntactic sugar.
        /// In this example, we'll call `stream` as a function, passing in a `Reducer.Action`
        /// to perform each time a new event is received.
        /// ```
        /// extension FooReducer {
        ///     func reduce(_ state: inout State, action: Action) -> Worker<Action> {
        ///         switch action {
        ///         case .observe:
        ///          return .stream(id: "MyStream") { stream in
        ///             for await value in SomeAsyncStream() {
        ///                 stream(.update(value))
        ///             }
        ///          }
        ///         case .update(let value):
        ///             print(value)
        ///         }
        ///     }
        /// }
        /// ```
        public func callAsFunction(_ action: U) {
            send(action)
        }
    }
}
