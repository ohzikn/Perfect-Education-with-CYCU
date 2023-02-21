//
//  ContentView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        PortalServicesView()
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
