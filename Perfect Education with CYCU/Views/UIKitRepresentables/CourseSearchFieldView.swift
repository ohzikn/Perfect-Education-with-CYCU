//
//  CourseSearchFieldView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/7.
//

import Foundation
import SwiftUI

struct CourseSearchFieldView: UIViewRepresentable {
    @EnvironmentObject var currentSession: CurrentSession
    @Binding var searchText: String
    
    let uiSearchBar = UISearchBar()
    var isFilterActivated: Binding<Bool>
    
    init(isFilterActivated: Binding<Bool>, searchText: Binding<String>) {
        self.isFilterActivated = isFilterActivated
        self._searchText = searchText
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        uiSearchBar.delegate = context.coordinator
        uiSearchBar.placeholder = "課程名稱"
        uiSearchBar.searchBarStyle = .minimal
        uiSearchBar.showsBookmarkButton = true
        uiSearchBar.setImage(.init(systemName: "slider.horizontal.3"), for: .bookmark, state: .normal)
        return uiSearchBar
    }
    
    func updateUIView(_ uiSearchBar: UISearchBar, context: Context) {
        uiSearchBar.text = searchText
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentSession: currentSession, isFilterActivated: self.isFilterActivated, searchText: $searchText)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let currentSession: CurrentSession
        var isFilterActivated: Binding<Bool>
        @Binding var searchText: String
        
        init(currentSession: CurrentSession, isFilterActivated: Binding<Bool>, searchText: Binding<String>) {
            self.currentSession = currentSession
            self.isFilterActivated = isFilterActivated
            self._searchText = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // Drop first responder to dismiss keyboard
//            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
        
        func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            isFilterActivated.wrappedValue.toggle()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
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
