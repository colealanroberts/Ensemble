//
//  StateInitializable.swift
//  
//
//  Created by Cole Roberts on 9/7/24.
//

import Foundation

/// A protocol that requires conforming types to provide a parameterless initializer.
/// - Note: This is particularly useful when all State properties are initialized by default.
public protocol StateInitializable: Equatable {
    init()
}

/// This extension provides a default implementation for retrieving the initial state
/// from a `Reducer.State` conforming to `StateInitializable`.
public extension Reducing where Self.State: StateInitializable {
    func initialState() -> State { .init() }
}
