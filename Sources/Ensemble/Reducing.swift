import SwiftUI

// MARK: - Reducing

/// The `Reducing` protocol defines a set of requirements for creating a reducer
/// that can be used with the `Store` class.
public protocol Reducing {
    
    /// The type of action that can be dispatched to the reducer.
    associatedtype Action
    
    /// The type of state that the reducer manages.
    associatedtype State: Equatable

    /// Returns the initial state for the reducer.
    func initialState() -> State
    
    /// Takes a mutable state object and an action and applies the action to
    /// the state object. Returns an optional effect action.
    func reduce(_ state: inout State, action: Action) -> Worker<Action>
}
