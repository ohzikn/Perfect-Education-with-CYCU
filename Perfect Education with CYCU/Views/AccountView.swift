//
//  AccountView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI
import LocalAuthentication

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    @State var isLogoutConfirmationDialogPresented = false
    
    let laContext = LAContext()
    
    init() {
        // Call canEvaluatePolicy to ensure device supported biometric type.
        var nsError: NSError?
        laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("基本資料") {
                    LabeledContent("姓名", value: currentMyselfSession.userInformation?.userName ?? "")
                    LabeledContent("CYCU ID", value: currentMyselfSession.userInformation?.userId ?? "")
                    LabeledContent("帳戶類型", value: currentMyselfSession.userInformation?.userType ?? "")
                }
                Section {
                    if laContext.biometryType != .none {
                        Toggle("使用 \(laContext.biometryType == .faceID ? "Face ID" : "Touch ID") 登入", isOn: applicationParameters.$usesBiometricLogin)
                    }
                }
                Section {
                    Button("登出...") {
                        isLogoutConfirmationDialogPresented = true
                    }
                    .confirmationDialog("", isPresented: $isLogoutConfirmationDialogPresented) {
                        Button("登出") {
                            currentMyselfSession.loginState = .notLoggedIn
                        }
                        Button("登出並刪除資料", role: .destructive) {
                            currentMyselfSession.loginState = .notLoggedIn
                            try? KeychainService.resetKeychain()
                        }
                        Button("取消", role: .cancel) { }
                    }
                }
            }
            .navigationTitle("帳戶")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var currentSession: CurrentMyselfSession = {
        var session = CurrentMyselfSession()
        return session
    }()
    static var previews: some View {
        AccountView()
            .environmentObject(ApplicationParameters())
            .environmentObject(currentSession)
    }
}
