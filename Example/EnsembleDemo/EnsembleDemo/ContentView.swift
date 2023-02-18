//
//  ContentView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var store: Store<CounterStore>
    
    var body: some View {
        NavigationView { store.view }
    }
}

