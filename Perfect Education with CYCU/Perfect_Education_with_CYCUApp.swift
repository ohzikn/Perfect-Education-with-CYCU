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
    @StateObject var currentSession = CurrentSession()
    
    var body: some Scene {
        WindowGroup {
            ControllerView()
                .environmentObject(applicationParameters)
                .environmentObject(currentSession)
        }
    }
}

final class ApplicationParameters: ObservableObject {
    // Saved paraeters
    @AppStorage(UserDefaults.toggleKeyValues.usesFaceId.rawValue) var usesBiometricLogin: Bool = false
    @AppStorage(UserDefaults.toggleKeyValues.isExtendedPersonalDataUseAuthorized.rawValue) var isExtendedPersonalDataUseAuthorized: Bool = false
}
