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
final class Store<Reducer: Reducing>: ObservableObject {
    
    // MARK: - `Private Properties` -
    
    /// The `Reducer` instance passed in the initializer.
    private let reducer: Reducer
    
    /// The current state of the `Store`
    @Published var state: Reducer.State
    
    /// The current view rendered by the `Reducer` instance.
    @Published var view: Reducer.Rendering?
    
    /// The `Sink` instance used by the `Reducer` instance.
    private (set) var sink: Sink<Reducer>?
    
    /// Sends actions to the `reduce` method.
    private var subject = PassthroughSubject<Reducer.Action, Never>()
    
    /// A set of `AnyCancellable` instances used to store the cancellable objects created by the `reduce` method.
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - `Init` -
    
    init(
        _ reducer: Reducer
    ) {
        self.reducer = reducer
        self.cancellables = .init()
        let state = reducer.initialState()
        self.state = state
        let sink = Sink<Reducer>(self)
        self.view = reducer.render(sink, state)
        self.sink = sink
        self.reduce(reducer)
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
            if let effect = reducer.reduce(&copy, action: action) {
                _ = reducer.reduce(&copy, action: effect)
                self?.runEffect(effect)
            }
            return copy
        }
        .receive(on: DispatchQueue.main)
        .sink {
            self.state = $0
            self.view = reducer.render(sink, $0)
        }
        .store(in: &cancellables)
    }
    
    /// Asynchronous actions that are returned by the `Reducer`'s `reduce` method.
    /// It runs the asynchronous action and sends the resulting action to the `subject` instance by calling the `send` method.
    private func runEffect(_ action: Reducer.Action) {
        Task {
            if let action = try await action.worker() {
                send(action)
            }
        }
    }
}
