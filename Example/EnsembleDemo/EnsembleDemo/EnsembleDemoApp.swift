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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Store(CounterStore()))
        }
    }
}
