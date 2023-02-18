//
//  SectionView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import SwiftUI

struct SectionView: View {
    
    @Namespace private var selectionIndicator
    @Environment(\.colorScheme) var colorScheme
    
    let selectedSection: Section
    let sections: [Section]
    let sink: Sink<RootStore>
    
    var body: some View {
        VStack {
            Spacer()
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        ForEach(sections, id: \.self) { section in
                            VStack {
                                PillView(
                                    proxy: proxy,
                                    section: section,
                                    selected: section == selectedSection,
                                    sink: sink
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            Spacer()
            Divider()
        }
    }
}

// MARK: - `SectionView+PillView`

fileprivate extension SectionView {
    struct PillView: View {
        
        let proxy: ScrollViewProxy
        let section: Section
        let selected: Bool
        let sink: Sink<RootStore>
        
        var body: some View {
            Text(section.title)
                .onTapGesture {
                    withAnimation {
                        sink.send(.selectSection(section))
                        proxy.scrollTo(section.title, anchor: .center)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(selected ? .white : .clear)
                .foregroundColor(selected ? .black : .white)
                .cornerRadius(20.0)
                .id(section.title)
        }
    }
}
