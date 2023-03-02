//
//  ControllerView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct ControllerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    @State private var isLoginSheetPresented = false
    
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
                    .navigationTitle(currentMyselfSession.greetingString)
                }
                .disabled(true)
            }
        }
        .sheet(isPresented: $isLoginSheetPresented) {
            LoginView()
                .interactiveDismissDisabled()
        }
        .onAppear {
            // Decide whether to show the login sheet when this view (controller) appears
            if currentMyselfSession.userInformation == nil || currentMyselfSession.userInformation?.didLogIn != "Y" {
                isLoginSheetPresented = true
            }
        }
        .onChange(of: scenePhase) { newValue in
            // Check if login has died and try to recover if so.
            if newValue == .active {
//                // Only proceed if currently logged in
//                guard currentSession.loginState == .loggedIn else { return }
//                // Log in again if scene phase became active
//                Task {
//                    let credentials = try KeychainService.retrieveLoginCredentials(for: try KeychainService.retrieveLoginInformation())
//                    await currentSession.requestLogin(username: credentials.username, password: credentials.password ?? "")
//                }
            }
        }
        .onChange(of: currentMyselfSession.loginState) { newValue in
            switch newValue {
            case .loggedIn:
                isLoginSheetPresented = false
                // Load all related data
                Task {
                    // Election
                    await currentMyselfSession.requestElection(method: .ann_get)
                    await currentMyselfSession.requestElection(method: .stage_control_get)
                    await currentMyselfSession.requestElection(method: .st_base_info)
                    await currentMyselfSession.requestElection(method: .st_info_get)
                    await currentMyselfSession.requestElection(method: .st_record)
                    // Credits
                    await currentMyselfSession.requestCredits()
                }
            case .notLoggedIn:
                // Show login sheet if logged out.
                isContentViewPresented = false
                isLoginSheetPresented = true
            case .failed(_):
                isLoginSheetPresented = true
            default:
                break
            }
        }
        .onChange(of: isLoginSheetPresented) { newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.25).delay(0)) {
                    isWelcomeMessageShowed = true
                }
                withAnimation(.easeIn(duration: 0.5).delay(1)) {
                    isWelcomeMessageShowed = false
                }
                withAnimation(.easeOut(duration: 0.5).delay(1.25)) {
                    isContentViewPresented = true
                }
            } else {
                isContentViewPresented = false
            }
        }
    }
}

struct ControllerView_Previews: PreviewProvider {
    static var currentSession: CurrentMyselfSession = {
        var session = CurrentMyselfSession()
//        session.isLoginSheetPresented = false
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
