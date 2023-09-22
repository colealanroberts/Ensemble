//
//  RootView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import SwiftUI

struct RootView: View {
    @State var rootStore: Store<RootStore>
    var body: some View { rootStore.view }
}
