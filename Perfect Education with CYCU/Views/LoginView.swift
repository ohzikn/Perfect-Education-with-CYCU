//
//  LoginView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    @Binding var isThisSheetPresented: Bool
    
    @State var isLoginProcessRingPresented = false
    @State var isLoginFailureAlertPresented = false
    @State var isSafariSheetPresented = false
    
    enum Field: Hashable {
        case username
        case password
    }
    
    enum Functions {
        case loginWelcome
    }
    
    @State private var presentedFunctions: [Functions] = []
    
    @State private var usernameField = ""
    @State private var passwordField = ""
    
    @FocusState private var focusedField: Field?
    
    private func requestLogin() {
        // Login guard
        guard !usernameField.isEmpty && !passwordField.isEmpty && (currentSession.loginState == .notLoggedIn || currentSession.loginState == .failed) else {
            return
        }
        currentSession.requestLogin(username: usernameField, password: passwordField)
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
                                .focused($focusedField, equals: .password)
                                .submitLabel(.return)
                                .onSubmit(requestLogin)
                        }
                        .padding([.leading, .trailing])
                        Divider()
                    }
                    .textFieldStyle(.plain)
                    .padding([.top, .bottom], 18)
                    Button("忘記 CYCU ID ？") {
                        isSafariSheetPresented.toggle()
                    }
                    VStack(spacing: 20) {
                        Text("你的 CYCU ID 是用來取用所有中原大學校內服務的帳號。")
                            .multilineTextAlignment(.center)
                        Image("CYCU-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                    }
                    .padding([.leading, .trailing])
                    .padding([.top], 40)
                }
            }
            .navigationDestination(for: Functions.self) { destination in
                switch destination {
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
    @EnvironmentObject var currentSession: CurrentSession
    
    @Binding var isThisSheetPresented: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 8) {
                    Text("設定 Face ID")
                        .font(.title)
                    Text("Face ID 可以讓你在下次登入時不必再次輸入密碼。")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                .padding([.leading, .trailing])
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("稍後設定") {
                    isThisSheetPresented = false
                }
            }
        }
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
