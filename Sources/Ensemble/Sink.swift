import SwiftUI

// MARK: - `Sink` -

/// `Sink` is a generic class that provides a way to interact with a `Store` by sending actions to it and
/// binding state values to corresponding reducer actions.
///
/// This class has two main responsibilities:
/// - Sending actions to the `Store` via the `send` method.
/// - Binding view properties to corresponding reducer actions via the `bindState` method.
public struct Sink<Reducer: Reducing> {
    
    // MARK: - `Private Properties` -
    
    /// The store this sink is associated with
    private let store: Store<Reducer>
    
    // MARK: - `Init` -
    
    /// Initializes a new sink with the given store.
    ///
    /// - Parameter store: The store associated with this sink.
    init(_ store: Store<Reducer>) {
        self.store = store
    }
    
    // MARK: - `Public Methods` -
    
    /// Sends the given action to the store.
    ///
    /// - Parameter action: The action to send to the store.
    public func send(_ action: Reducer.Action) {
        store.send(action)
    }
    
    /// Binds a view property to a corresponding reducer action.
    ///
    /// - Parameters:
    ///   - value: The key path to the state value to bind.
    ///   - action: The reducer action to send when the state value changes.
    /// - Returns: A binding to the state value.
    public func bindState<Value: Equatable & Sendable>(
        to value: KeyPath<Reducer.State, Value>,
        send action: @escaping @Sendable (Value) -> Reducer.Action
    ) -> Binding<Value> {
        .init(
            get: { store.state[keyPath: value] },
            set: { send(action($0)) }
        )
    }
}
