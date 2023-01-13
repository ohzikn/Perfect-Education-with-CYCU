//
//  SessionData.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import Foundation

@MainActor
class CurrentSession: ObservableObject {
    @Published var isLoginSheetPresented = true
    @Published var isLoginProcessing = false
    @Published var isLoginFailureAlertPresented = false
    @Published var greetingString:String = "請先登入"
    @Published var sessionInformation: Definitions.SessionInformation? {
        willSet {
            if let newValue, newValue.login_YN == "Y" {
                isLoginSheetPresented = false
                greetingString = (newValue.loginUser_CNAME == nil || newValue.loginUser_CNAME.unsafelyUnwrapped.isEmpty) ? "早安。" : "早安，\(newValue.loginUser_CNAME!)。"
            } else {
                isLoginSheetPresented = true
                greetingString = "請先登入"
            }
        }
    }
    
    func requestLogin(username: String, password: String) {
        // Create a credential data structure that will be converted to JSON data later
        struct Credentials: Codable {
            let UserNm: String
            let UserPasswd: String
        }
        
        // Response data
        struct ResponseData: Codable {
            var d_Message: String?
            var done_YN: String?
            var d_Message_C: String?
            var login_YN: String?
            var userID: String?
        }
        
        Task {
            defer {
                // Cleanups
                Task { @MainActor in
                    isLoginProcessing = false
                }
            }
            // Create a JSON object that will be posted to the server later.
            let credentialData = try JSONEncoder().encode(Credentials(UserNm: username, UserPasswd: password))
            
            // Create a HTTPS POST Request
            let request: URLRequest = {
               var req = URLRequest(url: Definitions.PortalLocations.login, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            isLoginProcessing = true
            
            // Send login request to server
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(ResponseData.self, from: data)
                guard response.login_YN == "Y" else {
                    isLoginFailureAlertPresented = true
                    sessionInformation = nil
                    return
                }
                // Request basic information
                requestBaseInfo(for: .base)
            } catch {
                isLoginFailureAlertPresented = true
                sessionInformation = nil
            }
        }
    }
    
    func requestBaseInfo(for request: Definitions.AuthenticateLocations) {
        // Create a credential data structure that will be converted to JSON data later
        struct Credentials: Codable {
            let authUrl: String
            let authApi: String
        }
        
        Task {
            // Create a JSON object that will be posted to the server later.
            let credentialData = try JSONEncoder().encode(Credentials(authUrl: Definitions.AuthenticateLocations.authRoot.rawValue, authApi: request.rawValue))
            
            // Create a HTTPS POST Request
            let request: URLRequest = {
               var req = URLRequest(url: Definitions.PortalLocations.baseInfo, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            
            // Send request to server
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                print(String(data: data, encoding: .utf8))
                sessionInformation = try JSONDecoder().decode(Definitions.SessionInformation.self, from: data)
                print(sessionInformation)
                if sessionInformation?.login_YN != "Y" {
                    isLoginFailureAlertPresented = true
                    sessionInformation = nil
                }
            } catch {
                // Logged in, but failed to get base info
                isLoginFailureAlertPresented = true
                sessionInformation = nil
            }
        }
    }
    
    func requestWorkStudy() {
        struct Credentials: Codable {
            let APP_AUTH_token: String
            let row: [String]
        }
        
        Task {
            let urlWithQuery: URL = {
                var url: URL = Definitions.PortalLocations.getAuthenticationLocation(for: .workStudy)
                let queries: [URLQueryItem] = [.init(name: "method", value: "query"), .init(name: "loginToken", value: sessionInformation?.loginToken)]
                url.append(queryItems: queries)
                return url
            }()
            
            let credentialData = try JSONEncoder().encode(Credentials(APP_AUTH_token: sessionInformation?.APP_AUTH_token ?? "", row: []))
            
            let request: URLRequest = {
                var req = URLRequest(url: urlWithQuery, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                print(String(data: data, encoding: .utf8))
            } catch {
                
            }
        }
    }
    
//    func requestElectionData(command: Definitions.ElectionCommands) {
//        // Create a comand structure that will be converted to JSON later
////        struct Credentials: Codable {
////            let method: String
////            let loginToken: String
////        }
//        struct Credentials: Codable {
//            let APP_AUTH_token: String
//            let mobile: String
//        }
//
//        Task {
//            // Create a JSON object that will be posted to the server later.
//            let credentialData = try JSONEncoder().encode(Credentials(APP_AUTH_token: userinfo, mobile: <#T##String#>))
//
//            // Creates a HTTPS POST request
//            let request: URLRequest = {
//                var req = URLRequest(url: Definitions.PortalLocations.election, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
//                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                req.httpMethod = "POST"
//                req.httpBody = credentialData
//                return req
//            }()
//
//            // Send request to server
//            do {
//                let (data, _) = try await URLSession.shared.data(for: request)
//                print(String(data: data, encoding: .utf8))
//            } catch {
//                print(error)
//            }
//        }
//    }
}
