//
//  EnsembleDemoApp.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import SwiftUI

@main
struct EnsembleDemoApp: App {
    
    // MARK: - `Private Properties` -
    
    private let sectionProvider: SectionProviding
    private let rootStore: RootStore
    
    // MARK: - `Init` -
    
    init() {
        let sectionProvider = SectionProvider(
            decoder: .init(),
            urlSession: .shared,
            userDefaults: .standard
        )
        self.sectionProvider = sectionProvider
        
        let rootStore = RootStore(
            sectionProvider: sectionProvider
        )
        
        self.rootStore = rootStore
    }
    
    // MARK: - `Body` -
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(Store(rootStore))
        }
    }
}
