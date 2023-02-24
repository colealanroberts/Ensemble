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
    func send(_ action: Reducer.Action) {
        subject.send(action)
    }
    
    // MARK: - `Private Methods` -
    
    /// Receives actions from the `subject`, reduces them, and updates the store's state and view.
    /// It uses a `scan` operator to update the state and returns the updated state in a `sink` operator to update the view.
    private func reduce(_ reducer: Reducer) {
        subject.scan(state) { [weak self] current, action in
            var copy = current
            let worker = reducer.reduce(&copy, action: action)
            switch worker.operation {
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
    
    /// Asynchronous actions that are returned by the `Reducer`'s `reduce` method.
    /// It runs the asynchronous action and sends the resulting action to the `subject` instance by calling the `send` method.
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
                if let onError = onError {
                    send(onError(error))
                }
            }
        }
    }
}
