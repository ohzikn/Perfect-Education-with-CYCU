//
//  SFSafariView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/12.
//

import SwiftUI
import Foundation
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
    let sfSafariView: SFSafariViewController
    
    init(url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false
        configuration.entersReaderIfAvailable = false
        sfSafariView = SFSafariViewController(url: url, configuration: configuration)
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return sfSafariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}
