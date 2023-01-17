//
//  SessionData.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import Foundation
import Security

@MainActor
class CurrentSession: ObservableObject {
    enum LoginState {
        case notLoggedIn
        case processing
        case failed
        case loginKeychainSetup
        case loggedIn
    }
    
    enum RequestError: Error {
        case authenticateTokenRequestFailed
        case queryRequestFailed
    }
    
    // Application token information
    struct ApplicationToken {
        let authenticateLocation: String
        let authenticateInformation: Definitions.AuthenticateInformation
    }
    
    @Published var greetingString:String = "請先登入"
    
    // MARK: User session related data start
    @Published var loginState: LoginState = .notLoggedIn {
        willSet {
            switch newValue {
            case .notLoggedIn, .failed:
                currentApplicationToken = nil
                userInformation = nil
                workStudyInformation = nil
                creditsInformation = nil
            default:
                break
            }
        }
    }
    @Published var currentApplicationToken: ApplicationToken?
    
    // User data queries
    @Published var userInformation: Definitions.UserInformation? {
        willSet {
            if let newValue, newValue.didLogIn == "Y" {
                greetingString = (newValue.userName == nil || newValue.userName.unsafelyUnwrapped.isEmpty) ? "早安。" : "早安，\(newValue.userName!.trimmingCharacters(in: .whitespaces))。"
            }else {
                greetingString = "請先登入"
            }
        }
    }
    @Published var workStudyInformation: Definitions.WorkStudyInformation?
    @Published var creditsInformation: Definitions.CreditsInformation?
    // MARK: User session related data end
    
    func requestLogin(username: String, password: String) {
        Task {
            // Update login state
            loginState = .processing
            // Create a JSON object that will be posted to the server later.
            let loginCredentials = Definitions.LoginCredentials(username: username, password: password)
            let data = try JSONEncoder().encode(loginCredentials)
            
            // Create a HTTPS POST Request
            let request = getUrlRequest(urlQuery: Definitions.PortalLocations.login, credentialData: data)
//            isLoginProcessing = true
            
            // Send login request to server
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
//                print(data)
                userInformation = try JSONDecoder().decode(Definitions.UserInformation.self, from: data)
                guard userInformation?.didLogIn == "Y" else {
                    loginState = .failed
//                    isLoginFailureAlertPresented = true
                    userInformation = nil
                    return
                }
                
                // Determine if keychain item exists for current account
                if (try? KeychainService.retrieveLoginCredentials(for: .init(username: userInformation?.userId ?? "", password: nil))) != nil {
                    // Keychain item exists
                    loginState = .loggedIn
                } else {
                    // Keychain item do not exist
                    loginState = .loginKeychainSetup
                    // Show welcome screen and save login information to keychain
                    try? KeychainService.registerLoginInformation(for: loginCredentials)
                }
                // Request basic information
                Task {
                    try await requestAuthenticateToken(for: Definitions.QueryLocations.getRelatedAuthenticateLocation(.base)())
                }
            } catch {
//                print(error)
                loginState = .failed
            }
        }
    }
    
    func requestWorkStudy(forceReload: Bool = false) {
        guard workStudyInformation == nil || forceReload else {
            // Skip request if data exists and no forceReload request
            return
        }
        
        Task {
            do {
                let data = try await requestDataQuery(for: .workStudy)
                workStudyInformation = try JSONDecoder().decode(Definitions.WorkStudyInformation.self, from: data)
            } catch {
                
            }
        }
    }
    
    func requestCredits(forceReload: Bool = false) {
        guard creditsInformation == nil || forceReload else {
            // Skip request if data exists and no forceReload request
            return
        }
        
        Task {
            do {
                let data = try await requestDataQuery(for: .credits)
//                print(String(data: data, encoding: .utf8))
                creditsInformation = try JSONDecoder().decode(Definitions.CreditsInformation.self, from: data)
//                print(creditsInformation)
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

extension CurrentSession {
    // Return UrlRequest Object
    private func getUrlRequest(urlQuery: URL, credentialData: Data) -> URLRequest {
        var request = URLRequest(url: urlQuery, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = credentialData
        return request
    }
    
    // Request data query
    private func requestDataQuery(for queryLocation: Definitions.QueryLocations) async throws -> Data {
        struct Credentials: Codable {
            let APP_AUTH_token: String
        }
        
        // Get app token from stored variable if current category is present, otherwise request a new one immediately.
        let appToken = currentApplicationToken?.authenticateLocation == Definitions.QueryLocations.getRelatedAuthenticateLocation(queryLocation)() && currentApplicationToken?.authenticateInformation.APP_AUTH_token != nil ? currentApplicationToken?.authenticateInformation.APP_AUTH_token : try await requestAuthenticateToken(for: Definitions.QueryLocations.getRelatedAuthenticateLocation(queryLocation)())
        
        let credentialData = try JSONEncoder().encode(Credentials(APP_AUTH_token: appToken ?? ""))
        
        let urlWithQuery: URL = {
            var url: URL = Definitions.QueryLocations.getUrl(queryLocation)()
            let queries: [URLQueryItem] = [.init(name: "method", value: "query"), .init(name: "loginToken", value: userInformation?.loginToken)]
            url.append(queryItems: queries)
            return url
        }()
        
        let request = getUrlRequest(urlQuery: urlWithQuery, credentialData: credentialData)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            throw RequestError.queryRequestFailed
        }
    }
    
    // Requests a new application authenticate token
    // Only pass parameter string returned from Definitions.QueryLocations.getRelatedAuthenticateLocation() method.
    private func requestAuthenticateToken(for query: String) async throws -> String {
        // Create a credential data structure that will be converted to JSON data later
        struct Credentials: Codable {
            let authUrl: String
            let authApi: String
        }
        
        do {
            // Create a JSON object that will be posted to the server later.
            let credentialData = try JSONEncoder().encode(Credentials(authUrl: "/\(Definitions.PortalLocations.auth.lastPathComponent)", authApi: query))
            
            // Create a HTTPS POST Request
            let request: URLRequest = {
               var req = URLRequest(url: Definitions.PortalLocations.baseInfo, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            
            // Send request to server
            let (data, _) = try await URLSession.shared.data(for: request)
//            print(String(data: data, encoding: .utf8))
            currentApplicationToken = .init(authenticateLocation: query, authenticateInformation: try JSONDecoder().decode(Definitions.AuthenticateInformation.self, from: data))
//            print(currentApplicationToken)
            return currentApplicationToken?.authenticateInformation.APP_AUTH_token ?? ""
        } catch {
            throw RequestError.authenticateTokenRequestFailed
        }
    }
}
