//
//  RootStore.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import Foundation
import SwiftUI
import UIKit

// MARK: - `RootStore` -

struct RootStore: Reducing {
    let sectionProvider: SectionProviding
}

// MARK: - `State` -

extension RootStore {
    struct State: Equatable {
        
        var articles: [Article]
        
        var hasPerformedInitialLayout: Int
        
        var isFetching: Bool
        
        var isPresentingWebView: Bool
        
        var selectedArticle: Article?
        
        var selectedSection: Section
        
        var sections: [Section] {
            Section.allCases
        }
        
        var shouldAnimateLayoutChanges: Bool {
            isFetching && hasPerformedInitialLayout > 0
        }
    }
    
    func initialState() -> State {
        .init(
            articles: [],
            hasPerformedInitialLayout: 0,
            isFetching: false,
            isPresentingWebView: false,
            selectedArticle: nil,
            selectedSection: .home
        )
    }
    
    func reduce(_ state: inout State, action: Action) -> Worker<Action> {
        switch action {
        case .articles(let articles):
            state.isFetching = false
            state.articles = articles.filter(\.isPresentable)
        case .performedInitialLayout:
            state.hasPerformedInitialLayout += 1
        case .selectArticle(let article):
            state.selectedArticle = article
            state.isPresentingWebView = true
        case .selectSection(let section):
            state.selectedSection = section
            state.isFetching = true
            return .task {
                let articles = try await sectionProvider.fetch(for: section)
                return .articles(articles)
            }
        case .webview(let isPresented):
            state.isPresentingWebView = isPresented
        }
        return .none
    }
}

// MARK: - `Action` -

extension RootStore {
    enum Action: Equatable {
        case articles([Article])
        case performedInitialLayout
        case selectSection(Section)
        case selectArticle(Article)
        case webview(isPresented: Bool)
    }
}

// MARK: - `Render` -

extension RootStore {
    @MainActor func render(_ sink: Sink<RootStore>, _ state: State) -> some View {
        ZStack(alignment: .top) {
            VStack {
                ScrollView {
                    Spacer().frame(height: 112)
                    ForEach(state.articles) { article in
                        ArticleView(
                            article: article,
                            sink: sink
                        )
                    }
                    .onAppear {
                        sink.send(.performedInitialLayout)
                    }
                }
                .frame(maxWidth: 600)
                .animation(.easeIn, value: state.shouldAnimateLayoutChanges)
            }
            NavbarView(
                state: state,
                sink: sink
            )
            .frame(maxWidth: .infinity, maxHeight: 96)
        }
        .sheet(
            isPresented: sink.bindState(
                to: \.isPresentingWebView,
                send: { .webview(isPresented: $0) }
            ),
            content: {
                if let url = state.selectedArticle?.url {
                    WebView(url: url).ignoresSafeArea()
                }
            }
        )
        .onAppear {
            guard state.articles.isEmpty else { return }
            sink.send(.selectSection(state.selectedSection))
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
