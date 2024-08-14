//
//  WebView.swift
//  Monster Cards
//
//  Created by JXMUNOZ on 2/12/24.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
    }
}

