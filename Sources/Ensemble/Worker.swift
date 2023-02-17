//
//  Worker.swift
//  Koko
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `Worker` -

/// A box type for managing asynchronous work
public struct Worker<Reducer: Reducing> {
    
    /// The operation to run, returning an `Action` from the inferred `Reducer`
    let run: () async throws -> Reducer.Action?
}
