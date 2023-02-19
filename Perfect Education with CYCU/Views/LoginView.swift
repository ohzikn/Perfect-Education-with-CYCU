//
//  LoginView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
    @Binding var isThisSheetPresented: Bool
    
    @State var isLoginProcessRingPresented = false
    @State var isLoginFailureAlertPresented = false
    @State var isSafariSheetPresented = false
    
    @State var isLogoutConfirmationDialogPresented = false
    
    enum Field: Hashable {
        case username
        case password
    }
    
    enum Functions {
        case loginWelcome
    }
    
    @State private var presentedFunctions: [Functions] = []
    
    @State private var usernameField = ""
    @State private var isUsernamePlaceholderActive = false
    @State private var passwordField = ""
    
    @FocusState private var focusedField: Field?
    
    private func requestBiometricLogin() {
        // FaceId toggle guard
        guard applicationParameters.usesFaceId else { return }
        let context = LAContext()
//        context.localizedCancelTitle = "輸入密碼"
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return
        }
        Task {
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "登入 CYCU Portal")
                let credentials = try KeychainService.retrieveLoginCredentials(for: try KeychainService.retrieveLoginInformation())
                requestLogin(credentials: credentials)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Biometric login
    private func requestLogin(credentials: Definitions.LoginCredentials) {
        // FaceId toggle guard
        guard applicationParameters.usesFaceId else { return }
        // Login state check
        guard (currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed), let password = credentials.password else {
            return
        }
        passwordField = "            " // Placeholder update
        currentSession.requestLogin(username: credentials.username, password: password)
    }
    
    // Normal login
    private func requestLogin() {
        // Login state check
        guard !usernameField.isEmpty && !passwordField.isEmpty && (currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed) else {
            return
        }
        currentSession.requestLogin(username: usernameField, password: passwordField)
    }
    
    init(isThisSheetPresented: Binding<Bool>) {
        if let loginInfo = try? KeychainService.retrieveLoginInformation() {
            usernameField = loginInfo.username
            isUsernamePlaceholderActive = true
        }
        self._isThisSheetPresented = isThisSheetPresented
    }
    
    var body: some View {
        NavigationStack(path: $presentedFunctions) {
            ScrollView {
                VStack {
                    VStack(spacing: 8) {
                        Text("CYCU Portal")
                            .font(.title)
                        Text("登入你想用於取用中原大學校內服務的 CYCU ID。")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .padding([.leading, .trailing])
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            HStack {
                                Text("CYCU ID")
                                    .fontWeight(.medium)
                                Spacer()
                            }.frame(width: 100)
                            TextField("學號或教職員編號", text: $usernameField)
                                .frame(height: 60)
                                .disabled(isUsernamePlaceholderActive || (currentSession.loginState != .failed && currentSession.loginState != .notLoggedIn))
                                .foregroundColor(isUsernamePlaceholderActive ? Color.secondary : Color.primary)
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                            if isLoginProcessRingPresented {
                                ProgressView()
                            }
                        }
                        .padding([.leading, .trailing])
                        Divider()
                        HStack {
                            HStack {
                                Text("密碼")
                                    .fontWeight(.medium)
                                Spacer()
                            }.frame(width: 100)
                            SecureField("必填", text: $passwordField)
                                .frame(height: 60)
                                .disabled(currentSession.loginState != .failed && currentSession.loginState != .notLoggedIn)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.return)
                                .onSubmit(requestLogin)
                        }
                        .padding([.leading, .trailing])
                        Divider()
                    }
                    .textFieldStyle(.plain)
                    .padding([.top, .bottom], 18)
                    if(isUsernamePlaceholderActive) {
                        VStack(spacing: 18) {
                            if applicationParameters.usesFaceId {
                                Button {
                                    // Login with Face ID
                                    requestBiometricLogin()
                                } label: {
                                    Image(systemName: "faceid")
                                        .font(.largeTitle)
                                        .symbolRenderingMode(SymbolRenderingMode.hierarchical)
                                }
                                .disabled(!applicationParameters.usesFaceId)
                            }
                            Button("使用其他 CYCU ID 登入...") {
                                isLogoutConfirmationDialogPresented = true
                            }
                            .confirmationDialog("使用其他 CYCU ID 登入", isPresented: $isLogoutConfirmationDialogPresented) {
                                Button("登出並刪除資料", role: .destructive) {
                                    // Reset keychain and update UI to default state.
                                    try? KeychainService.resetKeychain()
                                    withAnimation(Animation.easeInOut(duration: 0.25)) {
    //                                    usernameField = ""
                                        isUsernamePlaceholderActive = false
                                    }
                                }
                                Button("取消", role: .cancel) { }
                            } message: {
                                Text("要登出這個 CYCU ID 嗎？")
                            }
                        }
                    } else {
                        Button("忘記 CYCU ID ？") {
                            isSafariSheetPresented = true
                        }
                    }
                    VStack(spacing: 20) {
                        Text("你的 CYCU ID 是用來取用所有中原大學校內服務的帳號。")
                            .multilineTextAlignment(.center)
                        Image("CYCU-logo")
                            .antialiased(true)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                    }
                    .padding([.leading, .trailing])
                    .padding([.top], 40)
                }
            }
            .navigationDestination(for: Functions.self) { value in
                switch value {
                case .loginWelcome:
                    LoginWelcomeView(isThisSheetPresented: $isThisSheetPresented)
                }
            }
            .alert("登入失敗", isPresented: $isLoginFailureAlertPresented, actions: {
                Button("好") { }
            }, message: {
                Text("CYCU ID 或密碼錯誤。")
            })
            .fullScreenCover(isPresented: $isSafariSheetPresented, content: {
                SFSafariView(url: Definitions.ExternalLocations.passwordReset)
                    .ignoresSafeArea()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("下一步", action: requestLogin)
                        .disabled(usernameField.isEmpty || passwordField.isEmpty || !(currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed))
                }
            }
        }
        .onChange(of: currentSession.loginState) { newValue in
            // Switch statements
            switch newValue {
            case .failed:
                // Show login failure alert
                isLoginFailureAlertPresented = true
            case .loginKeychainSetup:
                // Navigate to first setup
                presentedFunctions.append(.loginWelcome)
            case .loggedIn:
                // Dismiss this sheet, ControllerView will handle the rest.
                isThisSheetPresented = false
            default:
                break
            }
            
            // Other controls
            isLoginProcessRingPresented = (newValue == .processing)
        }
    }
}

struct LoginWelcomeView: View {
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
    @Binding var isThisSheetPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.largeTitle)
                .symbolRenderingMode(SymbolRenderingMode.hierarchical)
            Text("設定 Face ID")
                .font(.title)
            Text("Face ID 可以讓你在下次登入時不必再次輸入密碼。")
                .font(.title2)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                applicationParameters.usesFaceId = true
                isThisSheetPresented = false
            } label: {
                Text("啟用 Face ID")
                    .fontWeight(.medium)
                    .padding([.top, .bottom], 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button("稍後設定") {
                applicationParameters.usesFaceId = false
                isThisSheetPresented = false
            }
        }
        .padding([.top], 40)
        .padding([.leading, .trailing])
        .navigationBarBackButtonHidden()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        LoginView(isThisSheetPresented: .constant(true))
            .environmentObject(currentSession)
            .previewDisplayName("Login")
        LoginWelcomeView(isThisSheetPresented: .constant(true))
            .environmentObject(currentSession)
            .previewDisplayName("Login Welcome")
    }
}
