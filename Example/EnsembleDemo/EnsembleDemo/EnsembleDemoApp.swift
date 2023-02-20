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
    
    private let impactGenerator: UIImpactFeedbackGenerator
    private let sectionProvider: SectionProviding
    
    // MARK: - `Init` -
    
    init() {
        let sectionProvider = SectionProvider(
            decoder: .init(),
            urlSession: .shared,
            userDefaults: .standard
        )
        self.sectionProvider = sectionProvider
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        
        self.impactGenerator = impactGenerator
    }
    
    // MARK: - `Body` -
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(
                    Store(RootStore(
                        impactGenerator: impactGenerator,
                        sectionProvider: sectionProvider
                    ))
                )
        }
    }
}
