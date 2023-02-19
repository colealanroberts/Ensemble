//
//  Section.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/18/23.
//

import Foundation

// MARK: - `RootStore.Section` -

enum Section: Equatable, CaseIterable {
    case home
    case arts
    case science
    case unitedStates
    case world
    case technology
    case business
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .arts:
            return "Arts"
        case .science:
            return "Science"
        case .unitedStates:
            return "United States"
        case .world:
            return "World"
        case .technology:
            return "Technology"
        case .business:
            return "Business"
        }
    }
    
    var json: String {
        switch self {
        case .home:
            return "home"
        case .arts:
            return "arts"
        case .science:
            return "science"
        case .unitedStates:
            return "us"
        case .world:
            return "world"
        case .technology:
            return "technology"
        case .business:
            return "business"
        }
    }
}
