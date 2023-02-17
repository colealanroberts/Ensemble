//
//  Worker.swift
//  Koko
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `Worker` -

/// A box type for managing asynchronous work
public struct Worker<Reducer: Reducing>: Equatable {
    
    // MARK: - `Private Properties` -
    
    private let id = UUID()
    
    // MARK: - `Public` - 
    
    /// The operation to run, returning an `Action` from the inferred `Reducer`
    public let run: () async throws -> Reducer.Action?
    
    // MARK: - `Init` -
    
    public init(run: @escaping () async throws -> Reducer.Action?) {
        self.run = run
    }
    
    public static func == (lhs: Worker<Reducer>, rhs: Worker<Reducer>) -> Bool {
        lhs.id == rhs.id
    }
}
