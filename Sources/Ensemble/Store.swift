import Combine
import SwiftUI

// MARK: - `Store` -

/// A `Store` class manages state in a Redux-style architecture. The `Store` class takes a generic type `Reducer` that conforms to the `Reducing` protocol.
public final class Store<Reducer: Reducing>: ObservableObject {
    
    // MARK: - `Public Properties` -
    
    /// The current view rendered by the `Reducer` instance.
    @Published public private(set) var view: Reducer.Rendering?
    
    /// The current state of the `Store`
    @Published private(set) var state: Reducer.State
    
    /// The `Sink` instance used by the `Reducer` instance.
    lazy var sink: Sink<Reducer> = { .init(self) }()
    
    // MARK: - `Private Properties` -
    
    /// The `Reducer` instance passed in the initializer.
    private let reducer: Reducer
    
    /// Sends actions to the `reduce` method.
    private let subject: PassthroughSubject<Reducer.Action, Never>
    
    /// A set of `AnyCancellable` instances used to store the cancellable objects created by the `reduce` method.
    private var cancellables: Set<AnyCancellable>
    
    /// A dictionary containing active `Task`s, if any
    private var effectTasks: [String: Task<Void, Never>]
    
    // MARK: - `Init` -
    
    public init(
        _ reducer: Reducer
    ) {
        self.reducer = reducer
        self.cancellables = .init()
        self.effectTasks = .init()
        self.subject = .init()
        let state = reducer.initialState()
        self.state = state
        self.view = reducer.render(sink, state)
        self.reduce(reducer)
    }
    
    deinit {
        effectTasks.forEach { _, task in
            task.cancel()
        }
    }
    
    // MARK: - `Public Methods` -
    
    /// Sends an `Action` to the `subject` instance.
    /// - Parameter action: The action to dispatch
    func send(_ action: Reducer.Action) {
        subject.send(action)
    }
    
    // MARK: - `Private Methods` -
    
    /// Receives actions from the `subject`, reduces them, and updates the store's state and view.
    /// It uses a `scan` operator to update the state and returns the updated state in a `sink` operator to update the view.
    /// - Parameter reducer: The reducer on which to perform operations
    private func reduce(_ reducer: Reducer) {
        subject.scan(state) { [weak self] current, action in
            var copy = current
            let worker = reducer.reduce(&copy, action: action)
            switch worker.operation {
            case .stream(let priority, let operation):
                self?.runStream(
                    id: worker.id,
                    priority: priority,
                    operation: operation
                )
            case .task(let priority, let operation, let error):
                self?.runEffect(
                    id: worker.id,
                    priority: priority,
                    operation: operation,
                    error: error
                )
            case .none:
                break
            }
            return copy
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            guard let self = self else { return }
            self.state = $0
            self.view = reducer.render(self.sink, $0)
        }
        .store(in: &cancellables)
    }
    
    /// Runs a stream operation with the given `id`, `priority`, and `operation`.
    ///
    /// - Parameter id: A unique ID representing this work, this default may be overriden.
    /// - Parameter priority: The priority level of the stream.
    /// - Parameter operation: An asynchronous closure that takes a `Worker<Reducer.Action>.Stream<Reducer.Action>` object and produces events through it.
    private func runStream(
        id: String,
        priority: TaskPriority,
        operation: @escaping (Worker<Reducer.Action>.Stream<Reducer.Action>) async -> Void
    ) {
        if let previousTask = effectTasks[id] {
            previousTask.cancel()
        }
        var continuation: AsyncStream<Reducer.Action>.Continuation?
        let stream = AsyncStream<Reducer.Action> { ct in
            continuation = ct
        }
        continuation?.onTermination = { @Sendable [weak self] _ in
            if let _ = self?.effectTasks[id] {
                self?.effectTasks[id] = nil
            }
        }
        effectTasks[id] = Task(priority: priority) { [continuation] in
            await withTaskGroup(
                of: Void.self
            ) { group in
                _ = group.addTaskUnlessCancelled(priority: priority) {
                    guard let continuation else {
                        fatalError("Continuation should never be nil!")
                    }
                    await operation(.init(continuation))
                }
                _ = group.addTaskUnlessCancelled(priority: priority) {
                    for await action in stream {
                        self.send(action)
                    }
                }
            }
        }
    }
    
    /// This private function executes an asynchronous effect specified by an operation and optional error handler.
    ///
    /// - Parameter id: A unique ID representing this work, this default may be overridden.
    /// - Parameter priority: The priority at which the task should be executed.
    /// - Parameter operation: The asynchronous operation to perform.
    /// - Parameter onError: An optional error handler to handle any errors that may occur. If nil, the error will be ignored. If non-nil, the error handler should return an Action that will be sent back to the Store.
    private func runEffect(
        id: String,
        priority: TaskPriority,
        operation: @escaping () async throws -> Reducer.Action,
        error onError: ((any Error) -> Reducer.Action)?
    ) {
        if let previousTask = effectTasks[id] {
            previousTask.cancel()
        }
        effectTasks[id] = Task(priority: priority) {
            defer {
                if let _ = effectTasks[id] {
                    effectTasks[id] = nil
                }
            }
            do {
                try Task.checkCancellation()
                let action = try await operation()
                send(action)
            } catch {
                if let onError {
                    send(onError(error))
                }
            }
        }
    }
}
