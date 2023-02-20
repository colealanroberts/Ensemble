//
//  RootView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var rootStore: Store<RootStore>
    
    var body: some View {
        NavigationView {
            rootStore.view
        }
        .navigationViewStyle(.stack)
    }
}

