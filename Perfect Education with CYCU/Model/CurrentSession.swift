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
    
    enum AuthorizationState {
        case succeed
        case failed
        case reAuthorized
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
    
    enum CourseListType: CaseIterable {
        case take
        case track
        case register
        case wait
    }
    
    @Published var greetingString:String = "請先登入"
    
    // User session related data start
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
    @Published var electionInformation_stageControl: Definitions.ElectionDataStructures.StageControl?
    @Published var electionInformation_studentBaseInformation: Definitions.ElectionDataStructures.StudentBaseInformation?
    @Published var electionInformation_studentInformation: Definitions.ElectionDataStructures.StudentInformation?
    @Published var electionInformation_announcement: Definitions.ElectionDataStructures.Announcement?
    @Published var electionInformation_history: Definitions.ElectionDataStructures.History?
    // User session related data end
    
    // MARK: Login
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
    
    // MARK: WorkStudy
    func requestWorkStudy() {
        Task {
            do {
                let data = try await requestDataQuery(for: .workStudy)
                workStudyInformation = try JSONDecoder().decode(Definitions.WorkStudyInformation.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
    
    // MARK: Credits
    func requestCredits() {
        Task {
            do {
                let data = try await requestDataQuery(for: .credits)
                creditsInformation = try JSONDecoder().decode(Definitions.CreditsInformation.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: Election
    func requestElection(method: Definitions.ElectionCommands) {
        // Return unsupported commands
        switch method {
        case .course_get, .track_insert, .track_del, .take_course_and_register_insert, .take_course_and_register_del, .volunteer_set, .col_checkbox_upd:
            print("current command (\(method.rawValue)) is not eligible from this method.")
            return
        case .st_info_get:
            // Get student info
            struct CustomQuery: RequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var mobile: String = "N"
            }
            requestElection(method: method, query: CustomQuery())
        default:
            // Default behaviour
            requestElection(method: method, query: nil)
        }
    }
    
    // Query with CourseInformation array
    func requestElection(method: Definitions.ElectionCommands, courseInformation: [Definitions.ElectionDataStructures.CourseInformation]) {
        switch method {
        case .track_insert:
            struct CustomQuery: RequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var data: [Definitions.ElectionDataStructures.CourseInformation]
            }
            requestElection(method: method, query: CustomQuery(data: courseInformation))
        case .track_del:
            struct CustomQuery: RequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var track_data: [Definitions.ElectionDataStructures.CourseInformation]
            }
            requestElection(method: method, query: CustomQuery(track_data: courseInformation))
        default:
            print("current command (\(method.rawValue)) is not eligible from this method.")
            return
        }
    }
    
    // .course_get
    func requestElection(filterQuery: Definitions.ElectionDataStructures.CourseSearchRequestQuery?, filterType: Int = 0) {
        
        struct CustomQuery: RequestQueryBase, Codable {
            var APP_AUTH_token: String?
            var filters: Definitions.ElectionDataStructures.CourseSearchRequestQuery
            var filter_type: Int
        }
        
        requestElection(method: .course_get, query: CustomQuery(filters: filterQuery ?? .init(opCode: .init(), cname: .init(), crossCode: .init(), opStdy: .init(), teacher: .init(), nonStop: .init(), betDept: .init(), betBln: .init(), betBlnMdie: .init(), crossPbl: .init(), distance: .init(), deptDiv: .init(), deptCode: .init(), general: .init(), opType: .init(), opTime123: .init(), opCredit: .init(), man: .init(), opManSum: .init(), remain: .init(), regMan: .init(), emiCourse: .init()), filter_type: filterType))
    }
    
    // private final method
    private func requestElection(method: Definitions.ElectionCommands, query: RequestQueryBase?) {
        print("executing command (\(method.rawValue)).")
        Task {
            do {
                // Send query and wait for response
                let data: Data = try await requestDataQuery(for: .election, using: method.rawValue, query: query)
                
                // Recieve and decode response
                let responseString = String(data: data, encoding: .utf8)
                print(responseString)
                
                // Check if distinct_IP_IDCODE_alert warning activated
                switch await electionDidDeadCheck(data: data) {
                case .succeed:
                    // Continue execution
                    break
                case .failed:
                    // Return
                    return
                case .reAuthorized:
                    // Resend last query
                    requestElection(method: method, query: query)
                }
                
                decodeElectionResponse(method: method, data: data)
            } catch {
                print(error)
            }
        }
    }
    
    private func electionDidDeadCheck(data: Data) async -> AuthorizationState {
        struct DistinctIpIdCodeAlert: Codable {
            var distinctIpCodeAlert: String?
            private enum CodingKeys: String, CodingKey {
                case distinctIpCodeAlert = "distinct_IP_IDCODE_alert"
            }
        }
        
        let isElectionDead = try? JSONDecoder().decode(DistinctIpIdCodeAlert.self, from: data)
        
        // If distinctIpCodeAlert is not empty
        if !(isElectionDead?.distinctIpCodeAlert?.isEmpty ?? true) {
            struct DistinctIpIdCodeResponse: Codable {
                var insSuccess: Bool?
            }
            
            // Ask server to pass election authorization
            guard let responseData = try? await requestDataQuery(for: .election, using: Definitions.ElectionCommands.login_sys_upd.rawValue), let response = try? JSONDecoder().decode(DistinctIpIdCodeResponse.self, from: responseData), response.insSuccess ?? false else {
                // Failed to inheirit election authorization
                return .failed
            }
            // Succeed to inheirit election authorization
            return .reAuthorized
        }
        // Authorization status is good
        return .succeed
    }
    
    private func decodeElectionResponse(method: Definitions.ElectionCommands, data: Data) {
        do {
            switch method {
            case .st_info_get:
                electionInformation_studentInformation = try JSONDecoder().decode(Definitions.ElectionDataStructures.StudentInformation.self, from: data)
                CourseListType.allCases.forEach { value in
                    NotificationCenter.default.post(name: .courseListDidUpdate, object: value)
                }
            case .stage_control_get:
                electionInformation_stageControl = try JSONDecoder().decode(Definitions.ElectionDataStructures.StageControl.self, from: data)
            case .st_base_info:
                electionInformation_studentBaseInformation = try JSONDecoder().decode(Definitions.ElectionDataStructures.StudentBaseInformation.self, from: data)
            case .track_get, .track_insert, .track_del: // These methods returns the same data structure
                let response = try JSONDecoder().decode(Definitions.ElectionDataStructures.TrackingListResponse.self, from: data)
                updateStudentInformation(for: .track, courses: response.trackingList)
                // Broadcast updated list type to observers
                NotificationCenter.default.post(name: .courseListDidUpdate, object: CourseListType.track)
            case .st_record:
                electionInformation_history = try JSONDecoder().decode(Definitions.ElectionDataStructures.History.self, from: data)
            case .ann_get:
                electionInformation_announcement = try JSONDecoder().decode(Definitions.ElectionDataStructures.Announcement.self, from: data)
            case .course_get:
                let response = try JSONDecoder().decode(Definitions.ElectionDataStructures.CourseSearchRequestResponse.self, from: data)
                // Broadcast result to observers
                NotificationCenter.default.post(name: .searchResultDidUpdate, object: response)
            case .take_course_and_register_insert:
                break
            case .take_course_and_register_del:
                break
            case .login_sys_upd:
                break
            case .volunteer_set:
                break
            case .col_checkbox_upd:
                break
            }
        } catch {
            print(error)
        }
    }
    
    // Execute this method to publish changes to observers
    private func updateStudentInformation(for listType: CourseListType, courses: [Definitions.ElectionDataStructures.CourseInformation]?) {
        guard let courses else { return }
        switch listType {
        case .take:
            electionInformation_studentInformation?.takeCourseList = courses
        case .track:
            electionInformation_studentInformation?.trackList = courses
        case .register:
            electionInformation_studentInformation?.registerList = courses
        case .wait:
            electionInformation_studentInformation?.makeUpList = courses
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
