//
//  Store.swift
//  Koko
//
//  Created by Cole Roberts on 2/14/23.
//

import Combine
import SwiftUI

// MARK: - `Store` -

/// A `Store` class manages state in a Redux-style architecture. The `Store` class takes a generic type `Reducer` that conforms to the `Reducing` protocol.
public final class Store<Reducer: Reducing>: ObservableObject {
    
    // MARK: - `Private Properties` -
    
    /// The `Reducer` instance passed in the initializer.
    private let reducer: Reducer
    
    /// The current state of the `Store`
    @Published var state: Reducer.State
    
    /// The current view rendered by the `Reducer` instance.
    @Published public var view: Reducer.Rendering?
    
    /// The `Sink` instance used by the `Reducer` instance.
    private (set) var sink: Sink<Reducer>?
    
    /// Sends actions to the `reduce` method.
    private var subject = PassthroughSubject<Reducer.Action, Never>()
    
    /// A set of `AnyCancellable` instances used to store the cancellable objects created by the `reduce` method.
    private var cancellables: Set<AnyCancellable>
    
    private var effectTasks: [String: Task<Void, Never>]
    
    // MARK: - `Init` -
    
    public init(
        _ reducer: Reducer
    ) {
        self.reducer = reducer
        self.cancellables = .init()
        self.effectTasks = .init()
        let state = reducer.initialState()
        self.state = state
        let sink = Sink<Reducer>(self)
        self.view = reducer.render(sink, state)
        self.sink = sink
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
        guard let sink else {
            fatalError("Sink was unexpectedly nil!")
        }
        subject.scan(state) { [weak self] current, action in
            var copy = current
            let worker = reducer.reduce(&copy, action: action)
            switch worker.operation {
            case .task(let operation):
                self?.runEffect(id: worker.id, operation: operation)
            case .none:
                break
            }
            return copy
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.state = $0
            self?.view = reducer.render(sink, $0)
        }
        .store(in: &cancellables)
    }
    
    /// Asynchronous actions that are returned by the `Reducer`'s `reduce` method.
    /// It runs the asynchronous action and sends the resulting action to the `subject` instance by calling the `send` method.
    private func runEffect(id: String, operation : @escaping () async -> Reducer.Action) {
        if let previousTask = effectTasks[id] {
            previousTask.cancel()
        }
        effectTasks[id] = Task {
            let action = await operation()
            send(action)
        }
    }
}
