//
//  LoginView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI
import LocalAuthentication
//import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
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
    
    let laContext = LAContext()
    
    init() {// Call canEvaluatePolicy to ensure device supported biometric type.
        var nsError: NSError?
        laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError)
    }
    
    private func requestBiometricLogin() {
        // FaceId toggle guard
        guard applicationParameters.usesBiometricLogin else { return }
//        let context = LAContext()
//        context.localizedCancelTitle = "輸入密碼"
        var error: NSError?
        guard laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return
        }
        Task {
            do {
                try await laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "登入 CYCU Portal")
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
        guard applicationParameters.usesBiometricLogin else { return }
        // Login state check
        guard (currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed(.unknown)), let password = credentials.password else {
            return
        }
        passwordField = "            " // Placeholder update
        Task {
            await currentSession.requestLogin(username: credentials.username, password: password)
        }
    }
    
    // Normal login
    private func requestLogin() {
        // Login state check
        guard !usernameField.isEmpty && !passwordField.isEmpty && (currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed(.unknown)) else {
            return
        }
        Task {
            await currentSession.requestLogin(username: usernameField, password: passwordField)
        }
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
                                .disabled(isUsernamePlaceholderActive || (currentSession.loginState != .failed(.unknown) && currentSession.loginState != .notLoggedIn))
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
                                .disabled(currentSession.loginState != .failed(.unknown) && currentSession.loginState != .notLoggedIn)
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
                            if applicationParameters.usesBiometricLogin {
                                Button {
                                    // Login with Face ID
                                    requestBiometricLogin()
                                } label: {
                                    Image(systemName: laContext.biometryType == .faceID ? "faceid" : "touchid")
                                        .font(.largeTitle)
                                        .symbolRenderingMode(SymbolRenderingMode.hierarchical)
                                }
                                .disabled(!applicationParameters.usesBiometricLogin)
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
                    LoginWelcomeView()
                }
            }
            .alert("登入失敗", isPresented: $isLoginFailureAlertPresented, actions: {
                Button("好") { }
            }, message: {
                // Completed: Update error message to dynamic message.
                if case CurrentSession.LoginState.failed(let loginError) = currentSession.loginState {
                    switch loginError {
                    case .userNameOrPasswordIncorrect:
                        Text("CYCU ID 或密碼錯誤。")
                    case .failedToRequestAuthenticateToken:
                        Text("無法取得認證密鑰。")
                    case .networkError(.noInternetConnection):
                        Text("網際網路尚未連線。")
                    case .networkError(.failedToEstablishSecureConnection):
                        Text("無法建立安全連線。")
                    case .unknown, .networkError(.unknown):
                        Text("發生未預期的錯誤。")
                    }
                }
            })
            .fullScreenCover(isPresented: $isSafariSheetPresented, content: {
                SFSafariView(url: Definitions.ExternalLocations.passwordReset)
                    .ignoresSafeArea()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("下一步", action: requestLogin)
                        .disabled(usernameField.isEmpty || passwordField.isEmpty || !(currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed(.unknown)))
                }
            }
        }
        .onAppear {
            if let loginInfo = try? KeychainService.retrieveLoginInformation() {
                usernameField = loginInfo.username
                isUsernamePlaceholderActive = true
            }
            if currentSession.loginState == CurrentSession.LoginState.failed(.unknown) {
                // Show login failure alert
                isLoginFailureAlertPresented = true
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
    
    @State var additionalMessage: String = ""
    
    let laContext = LAContext()
    var laError: LAError?
    
    init() {
        // IMPORTANT!! DO NOT ACCESS ENVIRONMENT OBJECTS HERE!! THIS WILL CAUSE FATAL ERROR!
        // Call canEvaluatePolicy to ensure device supported biometric type.
        var nsError: NSError?
        laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError)
        if let nsError {
            laError = LAError(_nsError: nsError)
        }
    }
    
    private func requestEnableBiometric() {
        var nsError: NSError?
        laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError)
        if let nsError {
            let laError = LAError(_nsError: nsError)
            print(laError)
            applicationParameters.usesBiometricLogin = false
        } else {
            applicationParameters.usesBiometricLogin = true
        }
        // Parent view will dismiss this sheet automatically for .loggedIn state
        currentSession.loginState = .loggedIn
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: laContext.biometryType == .faceID ? "faceid" : laContext.biometryType == .touchID ? "touchid" : "lock.square")
                .font(.largeTitle)
                .symbolRenderingMode(SymbolRenderingMode.hierarchical)
            Text("\(laContext.biometryType == .faceID ? "設定 Face ID" : laContext.biometryType == .touchID ? "設定 Touch ID" : "此裝置不支援 Face ID")")
                .font(.title)
            Text("\(laContext.biometryType == .faceID ? "Face ID 可以讓你在下次登入時不必再次輸入密碼。" : laContext.biometryType == .touchID ? "Touch ID 可以讓你在下次登入時不必再次輸入密碼。" : "你需要準備支援的裝置來使用 Face ID")")
                .font(.title2)
                .multilineTextAlignment(.center)
            Text(additionalMessage)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                requestEnableBiometric()
            } label: {
                Text("\(laContext.biometryType == .faceID ? "啟用 Face ID" : laContext.biometryType == .touchID ? "啟用 Touch ID" : "好")")
                    .fontWeight(.medium)
                    .padding([.top, .bottom], 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            if laContext.biometryType != .none {
                Button("稍後設定") {
                    requestEnableBiometric()
                }
            }
        }
        .padding([.top], 40)
        .padding([.bottom])
        .padding([.horizontal])
        .navigationBarBackButtonHidden()
        .onAppear {
            // Set additional message from LAError object returned code
            switch laError?.code {
            case .passcodeNotSet:
                additionalMessage = "你需要先設定裝置密碼來開始使用 \(laContext.biometryType == .faceID ? "Face ID" : "Touch ID")"
            case .biometryNotEnrolled, .touchIDNotEnrolled:
                additionalMessage = "你需要先設定 \(laContext.biometryType == .faceID ? "Face ID" : "Touch ID") "
            default:
                break
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        LoginView()
            .environmentObject(currentSession)
            .previewDisplayName("Login")
        LoginWelcomeView()
            .environmentObject(currentSession)
            .previewDisplayName("Login Welcome")
    }
}
