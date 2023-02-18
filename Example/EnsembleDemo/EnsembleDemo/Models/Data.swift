//
//  Data.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

struct Data<T: Decodable>: Decodable {
    let results: T
}
