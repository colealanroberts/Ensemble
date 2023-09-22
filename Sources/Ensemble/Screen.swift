import SwiftUI

// MARK: - `Screen` -

/// A SwiftUI view that encapsulates a stateful screen with a reducer.
public struct Screen<Content: View, Reducer: Reducing>: View {
    
    // MARK: - `Private Properties` -
    
    @State private var store: Store<Reducer>
    
    let content: (Sink<Reducer>, Reducer.State) -> Content
    
    // MARK: - `Init` -
    
    /// Initializes a new `Screen` view with a stateful reducer and a closure that provides the view content.
    ///
    /// - Parameters:
    ///   - reducer: The reducer that manages the state of the screen.
    ///   - content: A closure that takes a sink and the current state of the reducer as parameters and returns a `View`.
    public init(
        reducer: Reducer,
        @ViewBuilder _ content: @escaping (Sink<Reducer>, Reducer.State) -> Content
    ) {
        let store = Store(reducer)
        self.init(store: store, content)
    }
    
    /// Initializes a new `Screen` view with an existing store and a closure that provides the view content.
    ///
    /// - Parameters:
    ///   - store: An existing store that manages the state of the screen.
    ///   - content: A closure that takes a sink and the current state of the reducer as parameters and returns a `View`.
    public init(
        store: Store<Reducer>,
        @ViewBuilder _ content: @escaping (Sink<Reducer>, Reducer.State) -> Content
    ) {
        self.content = content
        self.store = store
    }
    
    // MARK: - `Body` -
    
    /// The view's body.
    public var body: some View {
        content(store.sink, store.state)
        
        let _ = Self._printChanges()
    }
}
