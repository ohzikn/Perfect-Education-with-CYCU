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
        TabView {
            PortalServicesView()
                .tabItem {
                    Label("線上服務", systemImage: "cloud")
                }
            AccountView()
                .tabItem {
                    Label("帳戶", systemImage: "person.circle")
                }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        ContentView()
            .environmentObject(currentSession)
    }
}
