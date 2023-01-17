//
//  ControllerView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct ControllerView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    @State private var isWelcomeMessageShowed = false
    @State private var isContentViewPresented = false
    
    var body: some View {
        ZStack {
            if isContentViewPresented {
                ContentView()
            }
            if isWelcomeMessageShowed {
                // Dummy navigation stack for displaying welcome message
                NavigationStack {
                    ZStack { }
                    .navigationTitle(currentSession.greetingString)
                }
                .disabled(true)
            }
        }
        .sheet(isPresented: $currentSession.isLoginSheetPresented) {
            LoginView()
                .interactiveDismissDisabled()
        }
        .onChange(of: currentSession.isLoginSheetPresented) { newValue in
            if !newValue {
                withAnimation(.easeOut(duration: 0.5).delay(0)) {
                    isWelcomeMessageShowed = true
                }
                withAnimation(.easeIn(duration: 0.25).delay(1)) {
                    isWelcomeMessageShowed = false
                }
                withAnimation(.easeOut(duration: 0.25).delay(1.25)) {
                    isContentViewPresented = true
                }
            } else {
                isContentViewPresented = false
            }
        }
    }
}

struct ControllerView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        session.isLoginSheetPresented = false
        return session
    }()
    static var previews: some View {
        ControllerView()
            .environmentObject(currentSession)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            .previewDisplayName("iPhone 13 Pro")
        ControllerView()
            .environmentObject(currentSession)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone 14 Pro")
    }
}
