//
//  NavbarView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/18/23.
//

import Ensemble
import SwiftUI

struct NavbarView: View {
    
    let state: RootStore.State
    let sink: Sink<RootStore>
    
    var body: some View {
        VStack {
            Spacer()
            LogoView()
            SectionView(
                selectedSection: state.selectedSection,
                sections: state.sections,
                sink: sink
            )
            .frame(height: 50)
            Spacer()
        }
        .background(.ultraThickMaterial)
        .frame(height: 96)
    }
}
