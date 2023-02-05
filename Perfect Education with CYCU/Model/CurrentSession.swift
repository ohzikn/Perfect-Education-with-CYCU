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
    
    // Application token structure
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
                electionInformation_stageControl = nil
                electionInformation_studentBaseInformation = nil
                electionInformation_studentInformation = nil
                electionInformation_announcement = nil
                electionInformation_history = nil
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
            } else {
                greetingString = "請先登入"
            }
        }
    }
    @Published var workStudyInformation: Definitions.WorkStudyInformation?
    @Published var creditsInformation: Definitions.CreditsInformation?
    @Published var electionInformation_stageControl: Definitions.ElectionInformation.StageControl?
    @Published var electionInformation_studentBaseInformation: Definitions.ElectionInformation.StudentBaseInformation?
    @Published var electionInformation_studentInformation: Definitions.ElectionInformation.StudentInformation?
    @Published var electionInformation_announcement: Definitions.ElectionInformation.Announcement?
    @Published var electionInformation_history: Definitions.ElectionInformation.History?
    // MARK: User session related data end
    
    func requestLogin(username: String, password: String) {
        Task {
            // Update login state
            loginState = .processing
            // Create a JSON object that will be posted to the server later.
            let loginCredentials = Definitions.LoginCredentials(username: username, password: password)
            let data = try JSONEncoder().encode(loginCredentials)
            
            // Create a HTTPS POST Request
            let request = getURLRequest(urlQuery: Definitions.PortalLocations.login, requestData: data)
            
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
                    try? KeychainService.updateLoginInformation(for: loginCredentials)
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
                print(error)
                loginState = .failed
            }
        }
    }
    
    func requestWorkStudy(skipIfDataExists: Bool = false) {
        guard workStudyInformation == nil || !skipIfDataExists else { return }
        Task {
            do {
                let data = try await requestDataQuery(for: .workStudy)
                workStudyInformation = try JSONDecoder().decode(Definitions.WorkStudyInformation.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
    func requestCredits(skipIfDataExists: Bool = false) {
        guard workStudyInformation == nil || !skipIfDataExists else { return }
        Task {
            do {
                let data = try await requestDataQuery(for: .credits)
                creditsInformation = try JSONDecoder().decode(Definitions.CreditsInformation.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
    func requestElection(skipIfDataExists: Bool = false, method: Definitions.ElectionCommands) {
        guard workStudyInformation == nil || !skipIfDataExists else { return }
        
        // Return unimplemented commands
        switch method {
        case .course_get, .track_insert, .track_del, .take_course_and_register_insert, .take_course_and_register_del, .volunteer_set, .col_checkbox_upd:
            print("current command (\(method.rawValue)) not implemented.")
            return
        default:
            print("executing command (\(method.rawValue)).")
            break
        }
        
        Task {
            do {
                // Initialize variables
                var data: Data?
                
                // Send request reffering by method type
                switch method {
                case .st_info_get:
                    struct SpecifiedQuery: RequestQueryBase, Codable {
                        var APP_AUTH_token: String?
                        var mobile: String = "N"
                    }
                    data = try await requestDataQuery(for: .election, using: method.rawValue, query: SpecifiedQuery())
                default:
                    // Default behaviour
                    data = try await requestDataQuery(for: .election, using: method.rawValue)
                }
                
                // Escape if data do not exist
                guard let data else { return }
                
                // Recieve and decode response referring by method type
                switch method {
                case .stage_control_get:
                    electionInformation_stageControl = try JSONDecoder().decode(Definitions.ElectionInformation.StageControl.self, from: data)
                case .st_base_info:
                    electionInformation_studentBaseInformation = try JSONDecoder().decode(Definitions.ElectionInformation.StudentBaseInformation.self, from: data)
                case .st_info_get:
                    electionInformation_studentInformation = try JSONDecoder().decode(Definitions.ElectionInformation.StudentInformation.self, from: data)
                case .ann_get:
                    electionInformation_announcement = try JSONDecoder().decode(Definitions.ElectionInformation.Announcement.self, from: data)
                case .st_record:
                    electionInformation_history = try JSONDecoder().decode(Definitions.ElectionInformation.History.self, from: data)
                case .track_get:
                    // Deprecated
//                    electionInformation_trackingList = try JSONDecoder().decode(Definitions.ElectionInformation.TrackingList.self, from: data)
                    break
                default:
                    break
                }
                
                let responseString = String(data: data, encoding: .utf8)
//                print(responseString)
            } catch {
                print(error)
            }
        }
    }
}

extension CurrentSession {
    // Returns URLRequest Object
    private func getURLRequest(urlQuery: URL, requestData: Data) -> URLRequest {
        var request = URLRequest(url: urlQuery, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestData
        return request
    }
    
    // Request data query. "query" is the default using parameter if not specified
    private func requestDataQuery(for queryLocation: Definitions.QueryLocations, using specifiedMethod: String = "query", query specifiedQuery: RequestQueryBase? = nil) async throws -> Data {
        
        // Create new request query to send along with the request following "RequestQueryBase" protocol
        var requestQuery = specifiedQuery ?? {
            struct DefaultQuery: RequestQueryBase, Codable {
                var APP_AUTH_token: String?
            }
            return DefaultQuery()
        }()
        
        // Get app token and set into requestQuery from stored variable if current category is present, otherwise request a new one immediately.
        requestQuery.APP_AUTH_token = currentApplicationToken?.authenticateLocation == Definitions.QueryLocations.getRelatedAuthenticateLocation(queryLocation)() && currentApplicationToken?.authenticateInformation.APP_AUTH_token != nil ? currentApplicationToken?.authenticateInformation.APP_AUTH_token : try await requestAuthenticateToken(for: Definitions.QueryLocations.getRelatedAuthenticateLocation(queryLocation)())
        
        // Encode requestQuery into data
        let requestData = try JSONEncoder().encode(requestQuery)
        
        // Get URL object
        let urlWithQuery: URL = {
            var url: URL = Definitions.QueryLocations.getUrl(queryLocation)()
            url.append(queryItems: [.init(name: "method", value: specifiedMethod), .init(name: "loginToken", value: userInformation?.loginToken)])
            return url
        }()
        
        // Get URLRequest object
        let request = getURLRequest(urlQuery: urlWithQuery, requestData: requestData)
        
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
