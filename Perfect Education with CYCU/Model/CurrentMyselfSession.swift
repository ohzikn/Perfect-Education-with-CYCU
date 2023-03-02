//
//  SessionData.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import Foundation
import Security
import LocalAuthentication

@MainActor
class CurrentMyselfSession: ObservableObject {
    enum LoginState: Equatable {
        case notLoggedIn
        case processing
        case failed(LoginError)
        case loginKeychainSetup
        case loggedIn
        
        static func == (lhs: LoginState, rhs: LoginState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoggedIn, .notLoggedIn):
                return true
            case (.processing, .processing):
                return true
            case (.loginKeychainSetup, .loginKeychainSetup):
                return true
            case (.loggedIn, .loggedIn):
                return true
            case (.failed(_), .failed(_)):
                // Ignoring associated values
                return true
            default:
                return false
            }
        }
    }
    
    enum LoginError {
        case networkError(NetworkError)
        case userNameOrPasswordIncorrect
        case failedToRequestAuthenticateToken
        case unknown
    }
    
    enum AuthorizationState {
        case succeed
        case failed
        case reAuthorized
    }
    
    enum NetworkError: Error {
        case noInternetConnection
        case failedToEstablishSecureConnection
        case unknown
    }
    
    // Application token structure
//    struct ApplicationToken {
//        let authenticateLocation: Definitions.QueryLocations
//        let authenticateInformation: Definitions.AuthenticateInformation
//    }
    
    enum CourseListType: CaseIterable {
        case take
        case track
        case register
        case wait
    }
    
    @Published var greetingString: String = "請先登入"
    
    // User session related data start
    @Published var loginState: LoginState = .notLoggedIn {
        willSet {
            switch newValue {
            case .notLoggedIn, .failed:
//                currentApplicationToken = nil
                currentSessionTokens.removeAll()
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
//    @Published var currentApplicationToken: ApplicationToken?
    @Published var currentSessionTokens: [MyselfDefinitions.QueryLocations: MyselfDefinitions.AuthenticateInformation] = [:]
    
    // User data queries
    @Published var userInformation: MyselfDefinitions.UserInformation? {
        willSet {
            if let newValue, newValue.didLogIn == "Y" {
                greetingString = (newValue.userName == nil || newValue.userName.unsafelyUnwrapped.isEmpty) ? "\(MyselfDefinitions().getCurrentDayPart().rawValue)。" : "\(MyselfDefinitions().getCurrentDayPart().rawValue)，\(newValue.userName.unsafelyUnwrapped)\(MyselfDefinitions().getCurrentDayPart().getHappyEmoji())。"
            } else {
                greetingString = "請先登入"
            }
            NotificationCenter.default.post(name: .myselfLoginInfoDidUpdate, object: newValue)
        }
    }
    @Published var workStudyInformation: MyselfDefinitions.WorkStudyInformation?
    @Published var creditsInformation: MyselfDefinitions.CreditsInformation?
    @Published var electionInformation_stageControl: MyselfDefinitions.ElectionDataStructures.StageControl?
    @Published var electionInformation_studentBaseInformation: MyselfDefinitions.ElectionDataStructures.StudentBaseInformation?
    @Published var electionInformation_studentInformation: MyselfDefinitions.ElectionDataStructures.StudentInformation?
    @Published var electionInformation_announcement: MyselfDefinitions.ElectionDataStructures.Announcement?
    @Published var electionInformation_history: MyselfDefinitions.ElectionDataStructures.History?
    // User session related data end
    
    // MARK: Login
    func requestLogin(username: String, password: String) async {// Authentication start
        do {
            // Update login state
            loginState = .processing
            // Create a JSON object that will be posted to the server later.
            let loginCredentials = MyselfDefinitions.LoginCredentials(username: username, password: password)
            let queryData = try JSONEncoder().encode(loginCredentials)
            
            // Create a HTTPS POST Request
            let request = getURLRequest(urlQuery: MyselfDefinitions.PortalLocations.login, headerData: queryData)
            // Send login request to server
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                print(data)
//                print(response)
//                print(error)
//            }.resume()
            let (data, _) = try await URLSession.shared.data(for: request)
            //                print(data)
            userInformation = try JSONDecoder().decode(MyselfDefinitions.UserInformation.self, from: data)
            guard userInformation?.didLogIn == "Y" else {
                loginState = .failed(.userNameOrPasswordIncorrect)
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
            do {
                try await requestBaseAuthenticateToken()
            } catch {
                loginState = .failed(.failedToRequestAuthenticateToken)
            }
        } catch {
            print("\((error as NSError).code)")
            switch (error as NSError).code {
            case -1021 ... -998:
                loginState = .failed(.networkError(.noInternetConnection))
            case -1206 ... -1200:
                loginState = .failed(.networkError(.failedToEstablishSecureConnection))
                break
            default:
                loginState = .failed(.networkError(.unknown))
            }
        }
    }
    
    func requestBaseAuthenticateToken() async throws {
        // There is no need to use base token, but leave for further use.
        try await requestAuthenticateToken(for: MyselfDefinitions.QueryLocations.base)
    }
    
    // MARK: WorkStudy
    func requestWorkStudy() async {
        do {
            let data = try await requestDataQuery(for: .workStudy)
            workStudyInformation = try JSONDecoder().decode(MyselfDefinitions.WorkStudyInformation.self, from: data)
        } catch {
            print(error)
        }
    }
    
    
    // MARK: Credits
    func requestCredits() async {
        do {
            let data = try await requestDataQuery(for: .credits)
            creditsInformation = try JSONDecoder().decode(MyselfDefinitions.CreditsInformation.self, from: data)
        } catch {
            print(error)
        }
    }
    
    // MARK: Election
    func requestElection(method: MyselfDefinitions.ElectionCommands) async {
        // Return unsupported commands
        switch method {
        case .course_get, .track_insert, .track_del, .take_course_and_register_insert, .take_course_and_register_del, .volunteer_set, .col_checkbox_upd:
            print("current command (\(method.rawValue)) is not eligible from this method.")
            return
        case .st_info_get:
            // Get student info
            struct CustomQuery: MyselfRequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var mobile: String = "N"
            }
            await requestElection(method: method, query: CustomQuery())
        default:
            // Default behaviour
            await requestElection(method: method, query: nil)
        }
    }
    
    // Query with CourseInformation array
    func requestElection(method: MyselfDefinitions.ElectionCommands, courseInformation: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) async {
        switch method {
        case .track_insert:
            struct CustomQuery: MyselfRequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var data: [MyselfDefinitions.ElectionDataStructures.CourseInformation]
            }
            await requestElection(method: method, query: CustomQuery(data: courseInformation))
        case .track_del:
            struct CustomQuery: MyselfRequestQueryBase, Codable {
                var APP_AUTH_token: String?
                var track_data: [MyselfDefinitions.ElectionDataStructures.CourseInformation]
            }
            await requestElection(method: method, query: CustomQuery(track_data: courseInformation))
        default:
            print("current command (\(method.rawValue)) is not eligible from this method.")
            return
        }
    }
    
    // .course_get
    func requestElection(filterQuery: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery?, filterType: Int = 0) async {
        struct CustomQuery: MyselfRequestQueryBase, Codable {
            var APP_AUTH_token: String?
            var filters: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery
            var filter_type: Int
        }
        
        await requestElection(method: .course_get, query: CustomQuery(filters: filterQuery ?? .init(opCode: .init(), cname: .init(), crossCode: .init(), opStdy: .init(), teacher: .init(), nonStop: .init(), betDept: .init(), betBln: .init(), betBlnMdie: .init(), crossPbl: .init(), distance: .init(), deptDiv: .init(), deptCode: .init(), general: .init(), opType: .init(), opTime123: .init(), opCredit: .init(), man: .init(), opManSum: .init(), remain: .init(), regMan: .init(), emiCourse: .init()), filter_type: filterType))
    }
    
    // private final method
    private func requestElection(method: MyselfDefinitions.ElectionCommands, query: MyselfRequestQueryBase?) async {
        print("executing command (\(method.rawValue)).")
        do {
            // Send query and wait for response
            let data: Data = try await requestDataQuery(for: .election, using: method.rawValue, query: query)
            
            // Recieve and decode response
            let responseString = String(data: data, encoding: .utf8)
            
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
                await requestElection(method: method, query: query)
            }
            
            decodeElectionResponse(method: method, data: data)
        } catch {
            print(error)
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
            guard let responseData = try? await requestDataQuery(for: .election, using: MyselfDefinitions.ElectionCommands.login_sys_upd.rawValue), let response = try? JSONDecoder().decode(DistinctIpIdCodeResponse.self, from: responseData), response.insSuccess ?? false else {
                // Failed to inheirit election authorization
                return .failed
            }
            // Succeed to inheirit election authorization
            return .reAuthorized
        }
        // Authorization status is good
        return .succeed
    }
    
    private func decodeElectionResponse(method: MyselfDefinitions.ElectionCommands, data: Data) {
        do {
            switch method {
            case .st_info_get:
                electionInformation_studentInformation = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.StudentInformation.self, from: data)
                CourseListType.allCases.forEach { value in
                    NotificationCenter.default.post(name: .courseListDidUpdate, object: value)
                }
            case .stage_control_get:
                electionInformation_stageControl = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.StageControl.self, from: data)
            case .st_base_info:
                electionInformation_studentBaseInformation = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.StudentBaseInformation.self, from: data)
            case .track_get, .track_insert, .track_del: // These methods returns the same data structure
                let response = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.TrackingListResponse.self, from: data)
                updateStudentInformation(for: .track, courses: response.trackingList)
                // Broadcast updated list type to observers
                NotificationCenter.default.post(name: .courseListDidUpdate, object: CourseListType.track)
            case .st_record:
                electionInformation_history = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.History.self, from: data)
            case .ann_get:
                electionInformation_announcement = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.Announcement.self, from: data)
            case .course_get:
                let response = try JSONDecoder().decode(MyselfDefinitions.ElectionDataStructures.CourseSearchRequestResponse.self, from: data)
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
    private func updateStudentInformation(for listType: CourseListType, courses: [MyselfDefinitions.ElectionDataStructures.CourseInformation]?) {
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

extension CurrentMyselfSession {
    // Returns URLRequest Object with header injection
    private func getURLRequest(urlQuery: URL, headerData: Data) -> URLRequest {
        var request = URLRequest(url: urlQuery, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = headerData
        return request
    }
    
    // Request data query. "query" is the default using parameter if not specified
    private func requestDataQuery(for queryLocation: MyselfDefinitions.QueryLocations, using specifiedMethod: String = "query", query specifiedQuery: MyselfRequestQueryBase? = nil) async throws -> Data {
        
        // Create new request query to send along with the request following "RequestQueryBase" protocol
        var requestQuery = specifiedQuery ?? {
            struct DefaultQuery: MyselfRequestQueryBase, Codable {
                var APP_AUTH_token: String?
            }
            return DefaultQuery()
        }()
        
        // Get app token and set into requestQuery from stored variable if current category is present, otherwise request a new one immediately.
        requestQuery.APP_AUTH_token = currentSessionTokens[queryLocation]?.APP_AUTH_token != nil ? currentSessionTokens[queryLocation]?.APP_AUTH_token : try await requestAuthenticateToken(for: queryLocation)
        
        // Encode requestQuery into data
        let requestData = try JSONEncoder().encode(requestQuery)
        
        // Get URL object
        let urlWithQuery: URL = {
            var url: URL = queryLocation.getUrl()
            url.append(queryItems: [.init(name: "method", value: specifiedMethod), .init(name: "loginToken", value: userInformation?.loginToken)])
            return url
        }()
        
        // Get URLRequest object
        let request = getURLRequest(urlQuery: urlWithQuery, headerData: requestData)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
//            print("Query response: \(String(data: data, encoding: .utf8))")
            return data
        } catch {
            print("\((error as NSError).code)")
            switch (error as NSError).code {
            case -1021 ... -998:
                throw NetworkError.noInternetConnection
            case -1206 ... -1200:
                throw NetworkError.failedToEstablishSecureConnection
            default:
                throw NetworkError.unknown
            }
        }
    }
    
    // Force requests a new application authenticate token even if token is already available
    // Only pass parameter string returned from Definitions.QueryLocations.getRelatedAuthenticateLocation() method.
    @discardableResult
    private func requestAuthenticateToken(for queryLocation: MyselfDefinitions.QueryLocations) async throws -> String {
        // Create a credential data structure that will be converted to JSON data later
        struct Credentials: Codable {
            let authUrl: String
            let authApi: String
        }
        
        do {
            // Create a JSON object that will be posted to the server later.
            let credentialData = try JSONEncoder().encode(Credentials(authUrl: "/\(MyselfDefinitions.PortalLocations.auth.lastPathComponent)", authApi: queryLocation.getRelatedAuthenticateLocation()))
            
            // Create a HTTPS POST Request
            let request: URLRequest = {
               var req = URLRequest(url: MyselfDefinitions.PortalLocations.baseInfo, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            
            // Send request to server
            let (data, _) = try await URLSession.shared.data(for: request)
            print("Auth return: \(String(data: data, encoding: .utf8))")
            
            currentSessionTokens[queryLocation] = try JSONDecoder().decode(MyselfDefinitions.AuthenticateInformation.self, from: data)
            print("Dictionary Token: \(currentSessionTokens[queryLocation]?.APP_AUTH_token)")
            
//            currentApplicationToken = .init(authenticateLocation: queryLocation, authenticateInformation: try JSONDecoder().decode(Definitions.AuthenticateInformation.self, from: data))
//            print(currentApplicationToken)
            return currentSessionTokens[queryLocation]?.APP_AUTH_token ?? ""
        } catch {
            print("\((error as NSError).code)")
            throw error
//            switch (error as NSError).code {
//            case -1021 ... -998:
//                throw NetworkError.noInternetConnection
//            case -1206 ... -1200:
//                throw NetworkError.failedToEstablishSecureConnection
//            default:
//                throw NetworkError.unknown
//            }
        }
    }
}
