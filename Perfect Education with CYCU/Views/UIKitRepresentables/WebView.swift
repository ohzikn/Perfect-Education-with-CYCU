//
//  WebView.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/29.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var markdown: String
    
    let webView = WKWebView()
    
    // Inject viewport markup before markdown to override HTML content scaling settings
    let viewportString =
"""
<meta name="viewport" content="width=device-width, initial-scale=1">
"""
    
    func makeUIView(context: Context) -> WKWebView {
//        webView.pageZoom = 2.0
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(viewportString + markdown, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                Task { @MainActor in
                    await UIApplication.shared.open(url)
                }
                return .cancel
            }
            return .allow
        }
        
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            if webView.isLoading == false {
//                webView.frame.size.height = webView.scrollView.contentSize.height
//            }
//        }
    }
}
