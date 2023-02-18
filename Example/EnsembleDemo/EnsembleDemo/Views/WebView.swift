//
//  WebView.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    
    let url: String

    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView(frame: .zero)
        webView.load(.init(url: URL(string: url)!))
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
