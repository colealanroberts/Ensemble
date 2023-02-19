//
//  LogoView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/18/23.
//

import SwiftUI

struct LogoView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Image("nyt")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .scaledToFit()
            .frame(width: 30, height: 28)
    }
}
