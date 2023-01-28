//
//  AccountView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
    @State var isLogoutConfirmationDialogPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("基本資料") {
                    LabeledContent("姓名", value: currentSession.userInformation?.userName ?? "")
                    LabeledContent("CYCU ID", value: currentSession.userInformation?.userId ?? "")
                    LabeledContent("帳戶類型", value: currentSession.userInformation?.userType ?? "")
                }
                Section {
                    Toggle("使用 Face ID 登入", isOn: applicationParameters.$usesFaceId)
                }
                Section {
                    Button("登出...") {
                        isLogoutConfirmationDialogPresented = true
                    }
                    .confirmationDialog("", isPresented: $isLogoutConfirmationDialogPresented) {
                        Button("登出") {
                            currentSession.loginState = .notLoggedIn
                        }
                        Button("登出並刪除資料", role: .destructive) {
                            currentSession.loginState = .notLoggedIn
                            try? KeychainService.resetKeychain()
                        }
                        Button("取消", role: .cancel) { }
                    }
                }
            }
            .navigationTitle("帳戶")
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
            .environmentObject(ApplicationParameters())
            .environmentObject(currentSession)
    }
}