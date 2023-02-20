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
    
    private var cache: [Section: [Article]]
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    private let userDefaults: UserDefaults
    
    // MARK: - `Init` -
    
    init(
        decoder: JSONDecoder,
        urlSession: URLSession,
        userDefaults: UserDefaults
    ) {
        self.cache = [:]
        self.decoder = decoder
        self.urlSession = urlSession
        self.userDefaults = userDefaults
    }
    
    func fetch(for section: Section) async -> [Article] {
        if let cached = cache[section], !userDefaults.shouldPerformFetch(for: section) {
            return cached
        }
        let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/\(section.slug).json?api-key=VS2HWCIFC39SUHtvqs0Lyqgv4oex0fk3")!
        do {
            let (data, _) = try await urlSession.data(from: url)
            let response = try decoder.decode(Data<[Article]>.self, from: data)
            let articles = response.results
            cache[section] = articles
            userDefaults.setLastCacheTime(for: section)
            return articles
        } catch {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
}

// MARK: - `UserDefaults` -

fileprivate extension UserDefaults {
    func setLastCacheTime(for section: Section) {
        setValue(Date.now, forKey: "__lastCacheTime_\(section.slug)")
    }
    
    func shouldPerformFetch(for section: Section) -> Bool {
        if let lastCached = value(forKey: "__lastCacheTime_\(section.slug)") as? Date {
            let soon = lastCached.addingTimeInterval(60 * 5)
            return Date.now > soon
        }
        
        return true
    }
}
