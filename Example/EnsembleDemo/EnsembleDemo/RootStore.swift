//
//  RootStore.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import Foundation
import NukeUI
import SwiftUI

struct RootStore: Reducing {
    let impactGenerator: UIImpactFeedbackGenerator
    let sectionProvider: SectionProviding
}

// MARK: - `State` -

extension RootStore {
    struct State: Equatable {
        
        var articles: [Article]
        
        let impactGenerator: UIImpactFeedbackGenerator
        
        var isFetching: Bool
        
        var isPresentingWebView: Bool
        
        var selectedArticle: Article?
        
        var selectedSection: Section
        
        var sections: [Section] {
            Section.allCases
        }
    }
    
    func initialState() -> State {
        .init(
            articles: [],
            impactGenerator: impactGenerator,
            isFetching: false,
            isPresentingWebView: false,
            selectedArticle: nil,
            selectedSection: .home
        )
    }
    
    func reduce(_ state: inout State, action: Action) -> Action? {
        switch action {
        case .articles(let articles):
            state.isFetching = false
            state.articles = articles.filter(\.isPresentable)
        case .webview(let isPresented):
            state.isPresentingWebView = isPresented
        case .selectArticle(let article):
            state.selectedArticle = article
            state.isPresentingWebView = true
        case .selectSection(let section):
            state.selectedSection = section
            state.isFetching = true
            state.impactGenerator.impactOccurred()
            
            return .worker(
                Worker {
                    let articles = try await sectionProvider.fetch(for: section)
                    return .articles(articles)
                }
            )
        case .worker(_):
            break
        }
        return nil
    }
}

// MARK: - `Action` -

extension RootStore {
    enum Action: Equatable, Working {
        case articles([Article])
        case selectSection(Section)
        case selectArticle(Article)
        case webview(isPresented: Bool)
        case worker(Worker<RootStore>)
        
        func worker() async throws -> RootStore.Action? {
            guard case .worker(let worker) = self else { return nil }
            return try await worker.run()
        }
    }
}

// MARK: - `Render` -

extension RootStore {
    @MainActor func render(_ sink: Sink<RootStore>, _ state: State) -> some View {
        VStack(spacing: 0) {
            SectionView(
                selectedSection: state.selectedSection,
                sections: state.sections,
                sink: sink
            )
            .frame(height: 50)
            
            List(state.articles) { article in
                LazyVStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(
                                .system(.title3, design: .serif)
                            )
                        
                        Text(article.abstract)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    
                    if let coverImageURL = article.coverImageURL {
                        LazyImage(
                            url: .init(string: coverImageURL)!
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 3.0))
                        .aspectRatio(contentMode: .fill)
                    }
                }
                .padding(6)
                .onTapGesture {
                    sink.send(.selectArticle(article))
                }
            }
            .animation(.easeIn, value: state.isFetching)
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
        .background(.black)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("nyt")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 30, height: 28)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(state.selectedSection.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
