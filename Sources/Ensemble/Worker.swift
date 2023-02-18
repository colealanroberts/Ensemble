//
//  Worker.swift
//  Koko
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `Worker` -

/// A box type for managing asynchronous work
public struct Worker<Action> {
    
    enum Operation {
        case none
        case task(() async -> Action)
    }
    
    let id: String = UUID().uuidString
    let operation: Operation
    
    // MARK: - `Init` -
    init(operation: Operation) {
        self.operation = operation
    }
}

extension Worker {
    public static var none: Self {
        Self(operation: .none)
    }
    
    public static func task(operation: @escaping () async -> Action) -> Self {
        Self(operation: .task(operation))
    }
}
