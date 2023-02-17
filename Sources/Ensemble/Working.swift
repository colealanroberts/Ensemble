//
//  Working.swift
//  Koko
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `Working` -

public protocol Working {
    func worker() async throws -> Self?
}
