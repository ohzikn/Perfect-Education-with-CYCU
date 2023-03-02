//
//  Perfect_Education_with_CYCUApp.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI

@main
struct Perfect_Education_with_CYCUApp: App {
    @StateObject var applicationParameters = ApplicationParameters()
    @StateObject var currentMyselfSession = CurrentMyselfSession()
    @StateObject var currentPalaceSession = CurrentPalaceSession()
    
    var body: some Scene {
        WindowGroup {
            ControllerView()
                .environmentObject(applicationParameters)
                .environmentObject(currentMyselfSession)
                .environmentObject(currentPalaceSession)
        }
    }
}

final class ApplicationParameters: ObservableObject {
    // Saved paraeters
    
    // Is the application launched initially after install.
    @AppStorage(UserDefaults.toggleKeyValues.isFirstLaunch.rawValue) var isFirstLaunch: Bool = true
    // Authenticate using FaceId or TouchId
    @AppStorage(UserDefaults.toggleKeyValues.usesFaceId.rawValue) var usesBiometricLogin: Bool = false
    // Extended personal data use (for extended features not maintained by school.)
    @AppStorage(UserDefaults.toggleKeyValues.isExtendedPersonalDataUseAuthorized.rawValue) var isExtendedPersonalDataUseAuthorized: Bool = false
    
    init() {
        // Reset keychain if application is launched at the first time (unremoved credentials while uninstalled.)
        if isFirstLaunch {
            try? KeychainService.resetKeychain()
            isFirstLaunch = false
        }
    }
}
