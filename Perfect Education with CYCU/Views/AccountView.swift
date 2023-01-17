//
//  AccountView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    @State var isLogoutConfirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                if let information = currentSession.userInformation {
                    Section("基本資料") {
                        LabeledContent("姓名", value: information.userName ?? "")
                        LabeledContent("CYCU ID", value: information.userId ?? "")
                        LabeledContent("帳戶類型", value: information.userType ?? "")
                    }
                    Section {
                        Button("登出") {
                            isLogoutConfirmationDialogPresented = true
                        }
                    }
                }
            }
            .navigationTitle("帳戶")
            .confirmationDialog("", isPresented: $isLogoutConfirmationDialogPresented) {
                Button("登出") {
                    currentSession.loginState = .notLoggedIn
                }
                Button("登出並刪除資料", role: .destructive) {
                    currentSession.loginState = .notLoggedIn
                    try? KeychainService.resetKeychain()
                }
                Button("取消", role: .cancel) {
                    
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        AccountView()
            .environmentObject(currentSession)
    }
}
