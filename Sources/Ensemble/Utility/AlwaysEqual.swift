//
//  AlwaysEqual.swift
//  
//
//  Created by Cole Roberts on 3/1/23.
//

import Foundation

/// A property wrapper that always returns `true` when compared for equality.
@propertyWrapper
public struct AlwaysEqual<Value>: Equatable {
    
    /// The wrapped value of the property.
    public var wrappedValue: Value
    
    /// Initializes an instance of `AlwaysEqual`.
    /// - Parameter wrappedValue: The value to be wrapped.
    public init(wrappedValue value: Value) {
        self.wrappedValue = value
    }
    
    /// Compares two instances of `AlwaysEqual` for equality.
    /// - Returns: `true`.
    public static func == (lhs: AlwaysEqual<Value>, rhs: AlwaysEqual<Value>) -> Bool {
        true
    }
}
