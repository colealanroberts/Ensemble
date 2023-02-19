//
//  ArticleView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/18/23.
//

import Ensemble
import NukeUI
import SwiftUI

struct ArticleView: View {
    
    let article: Article
    let sink: Sink<RootStore>
    
    var body: some View {
        VStack(spacing: 24) {
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
                .clipShape(RoundedRectangle(cornerRadius: 6.0))
                .aspectRatio(contentMode: .fill)
                .id(coverImageURL)
            }
            
            Divider()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .onTapGesture {
            sink.send(.selectArticle(article))
        }
        .id(article.url)
    }
}
