import SwiftUI

// MARK: - `Reducing` -

/// The `Reducing` protocol defines a set of requirements for creating a reducer
/// that can be used with the `Store` class.
public protocol Reducing {
    
    /// The type of action that can be dispatched to the reducer.
    associatedtype Action
    
    /// The type of state that the reducer manages.
    associatedtype State: Equatable
    
    /// The type of rendering that is generated from the state and is used
    /// to update the view.
    associatedtype Rendering: View
    
    /// Returns the initial state for the reducer.
    func initialState() -> State
    
    /// Takes a mutable state object and an action and applies the action to
    /// the state object. Returns an optional effect action.
    func reduce(_ state: inout State, action: Action) -> Worker<Action>
    
    /// Generates a rendering from the state object and a sink object that
    /// can be used to dispatch actions.
    func render(_ sink: Sink<Self>, _ state: State) -> Rendering
}

/// Provide a default implementation for any Store that wishes to utilize `Screen`,
/// where providing a `render(sink:state)->Rendering` implementation isn't necessary

public extension Reducing {
    func render(_ sink: Sink<Self>, _ state: State) -> EmptyView { EmptyView() }
}
