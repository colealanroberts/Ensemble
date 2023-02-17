//
//  Sink.swift
//  Koko
//
//  Created by Cole Roberts on 2/14/23.
//

import Foundation
import SwiftUI

// MARK: - `Sink` -

public struct Sink<Reducer: Reducing> {
    
    // MARK: - `Private Properties` -
    
    /// The store this sink is associated with
    private let store: Store<Reducer>
    
    // MARK: - `Init` -
    
    /// Initializes a new sink with the given store
    init(_ store: Store<Reducer>) {
        self.store = store
    }
    
    // MARK: - `Public Methods` - 
    
    /// Sends the given action to the store
    public func send(_ action: Reducer.Action) {
        store.send(action)
    }
    
    /// Binds a view property to a corresponding reducer action
    public func bindState<Value: Equatable>(
        _ value: KeyPath<Reducer.State, Value>,
        _ action: @Sendable @escaping (Value) -> Reducer.Action
    ) -> Binding<Value> {
        .init(
            get: { store.state[keyPath: value] },
            set: { send(action($0)) }
        )
    }
}
