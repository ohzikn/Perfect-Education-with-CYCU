//
//  SearchFieldView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/7.
//

import Foundation
import SwiftUI

struct SearchFieldView: UIViewRepresentable {
    @EnvironmentObject var currentSession: CurrentSession
    
    enum SearchCaller {
        case courseQuery
    }
    
    let uiSearchBar = UISearchBar()
    let queryType: SearchCaller
    
    init(for caller: SearchCaller) {
        self.queryType = caller
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        uiSearchBar.delegate = context.coordinator
        uiSearchBar.placeholder = "搜尋"
        uiSearchBar.searchBarStyle = .minimal
        return uiSearchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentSession: currentSession, for: queryType)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let queryType: SearchCaller
        let currentSession: CurrentSession
        
        init(currentSession: CurrentSession, for caller: SearchCaller) {
            self.currentSession = currentSession
            self.queryType = caller
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            print(searchText)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // Drop first responder to dismiss keyboard
            searchBar.resignFirstResponder()
            if let searchText = searchBar.text {
                // Executes query by caller type
                switch queryType {
                case .courseQuery:
                    currentSession.requestElection(filterQuery: .init(opCode: .init(), cname: .init(value: searchText), crossCode: .init(), opStdy: .init(), teacher: .init(), nonStop: .init(), betDept: .init(), betBln: .init(), betBlnMdie: .init(), crossPbl: .init(), distance: .init(), deptDiv: .init(), deptCode: .init(), general: .init(), opType: .init(), opTime123: .init(), opCredit: .init(), man: .init(), opManSum: .init(), remain: .init(), regMan: .init(), emiCourse: .init()))
                }
            }
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
