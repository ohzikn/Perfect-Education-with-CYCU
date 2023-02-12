//
//  CourseSearchView.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/2/12.
//

import Foundation
import SwiftUI

struct CourseSearchView: UIViewControllerRepresentable {
    @EnvironmentObject var currentSession: CurrentSession
    
    let rootViewController = UIViewController()
    let uiSearchBar = UISearchBar()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        uiSearchBar.translatesAutoresizingMaskIntoConstraints = false
//        uiSearchBar.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        uiSearchBar.delegate = context.coordinator
        uiSearchBar.placeholder = "課程名稱"
        uiSearchBar.searchBarStyle = .minimal
        uiSearchBar.showsBookmarkButton = true
        uiSearchBar.setImage(.init(systemName: "slider.horizontal.3"), for: .bookmark, state: .normal)
        
        rootViewController.view.addSubview(uiSearchBar)
        
        NSLayoutConstraint.activate([
            uiSearchBar.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
            uiSearchBar.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor)
        ])
        
        return rootViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentSession: currentSession)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let currentSession: CurrentSession
        
        init(currentSession: CurrentSession) {
            self.currentSession = currentSession
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // Drop first responder to dismiss keyboard
            searchBar.resignFirstResponder()
        }
        
        func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            let sheetViewController = UISheetPresentationController(presentedViewController: UIHostingController(rootView: AdvancedSearchView()), presenting: nil)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            print(searchText)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // Drop first responder to dismiss keyboard
            searchBar.resignFirstResponder()
            if let searchText = searchBar.text {
                currentSession.requestElection(filterQuery: .init(opCode: .init(), cname: .init(value: searchText), crossCode: .init(), opStdy: .init(), teacher: .init(), nonStop: .init(), betDept: .init(), betBln: .init(), betBlnMdie: .init(), crossPbl: .init(), distance: .init(), deptDiv: .init(), deptCode: .init(), general: .init(), opType: .init(), opTime123: .init(), opCredit: .init(), man: .init(), opManSum: .init(), remain: .init(), regMan: .init(), emiCourse: .init()))
            }
        }
    }
}
