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
                                    namespace: selectionIndicator,
                                    proxy: proxy,
                                    section: section,
                                    selectedId: selectedSection.title,
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
        
        let namespace: Namespace.ID
        let proxy: ScrollViewProxy
        let section: Section
        let selectedId: String
        let sink: Sink<RootStore>
        
        var selected: Bool {
            section.title == selectedId
        }
        
        var body: some View {
            ZStack {
                if selected {
                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(selected ? .white : .clear)
                        .cornerRadius(20.0)
                        .matchedGeometryEffect(id: "category", in: namespace)
                }
                    
                Text(section.title)
                    .foregroundColor(selected ? .black : .white)
                    .font(.system(size: 14, weight: .medium))
                    .id(section.title)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: selected
            )
            .onTapGesture {
                withAnimation {
                    sink.send(.selectSection(section))
                    proxy.scrollTo(section.title, anchor: .center)
                }
            }
        }
    }
}
