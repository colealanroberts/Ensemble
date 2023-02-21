//
//  Screen.swift
//
//
//  Created by Cole Roberts on 2/20/23.
//

import SwiftUI

public struct Screen<Content: View, Reducer: Reducing>: View {
    
    // MARK: - `StateObject` -
    
    @StateObject private var store: Store<Reducer>
    
    // MARK: - `Private Properties` -
    
    private let content: (Sink<Reducer>, Reducer.State) -> Content
    
    // MARK: - `Init` -
    
    public init(
        reducer: Reducer,
        @ViewBuilder _ content: @escaping (Sink<Reducer>, Reducer.State) -> Content
    ) {
        let store = Store(reducer)
        self.init(store: store, content)
    }
    
    public init(
        store: Store<Reducer>,
        @ViewBuilder _ content: @escaping (Sink<Reducer>, Reducer.State) -> Content
    ) {
        self.content = content
        self._store = StateObject(wrappedValue: store)
    }
    
    // MARK: - `Body` -
    
    public var body: some View {
        content(store.sink, store.state)
    }
}
