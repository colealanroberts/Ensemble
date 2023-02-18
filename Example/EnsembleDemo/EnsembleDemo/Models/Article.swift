//
//  Article.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `Article` -

struct Article: Decodable, Equatable, Identifiable, Hashable {
    
    var id: UUID {
        .init()
    }
    
    var isPresentable: Bool {
        url != "null" && title != ""
    }
    
    let section: String
    let title: String
    let abstract: String
    let url: String
    let multimedia: [Multimedia]?
    
    var coverImageURL: String? {
        multimedia?[1].url
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
  
// MARK: - `Article+Multimedia` -

extension Article {
    struct Multimedia: Decodable {
        let url: String
    }
}
