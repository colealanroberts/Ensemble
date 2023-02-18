//
//  SectionProvider.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Foundation

// MARK: - `SectionProviding` -

protocol SectionProviding {
    func fetch(for type: Section) async throws -> [Article]
}

// MARK: - `SectionProvider` -

final class SectionProvider: SectionProviding {
    
    // MARK: - `Private Properties` -
    
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    
    // MARK: - `Init` -
    
    init(
        decoder: JSONDecoder,
        urlSession: URLSession
    ) {
        self.decoder = decoder
        self.urlSession = urlSession
    }
    
    // MARK: - `Public Methods` -
    
    func fetch(for type: Section) async -> [Article] {
        let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/\(type.json).json?api-key=VS2HWCIFC39SUHtvqs0Lyqgv4oex0fk3")!
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response = try decoder.decode(Data<[Article]>.self, from: data)
            try await Task.sleep(for: .milliseconds(500))
            return response.results
        } catch {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
}
