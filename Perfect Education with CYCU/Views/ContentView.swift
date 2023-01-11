//
//  ContentView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        NavigationStack {
            TabView {
                VStack {
                    Button("Request data") {
//                        currentSession.requestElectionData(command: .course_get)
                    }
//                    List {
//                        if let navigationData = currentSession.navigationData {
//                            ForEach(navigationData) { section in
//                                Section(section.sectionName ?? "") {
//                                    if let items = section.items {
//                                        ForEach(items) { item in
//                                            if let name = item.itemName {
//                                                Text(name)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            }
            .navigationTitle(currentSession.greetingString)
            .sheet(isPresented: $currentSession.isLoginSheetPresented) {
                LoginView()
                    .interactiveDismissDisabled()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var sessionData: CurrentSession = {
        var sessionData = CurrentSession()
        sessionData.isLoginSheetPresented = false
        return sessionData
    }()
    static var previews: some View {
        ContentView()
            .environmentObject(sessionData)
    }
}
