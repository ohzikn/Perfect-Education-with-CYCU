//
//  CurrentPalaceSession.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/3/3.
//

import Foundation

@MainActor
class CurrentPalaceSession: ObservableObject {
    @Published var palaceCredentials: PalaceDefinitions.Credentials?
    @Published var authenticateToken: UUID?
    
    @Published var messageBoardItems: [PalaceDefinitions.MessageBoardResponse.MessageBoardItem] = []
    
    enum NetworkError: Error {
        case noInternetConnection
        case failedToEstablishSecureConnection
        case unknown
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePalaceCredentials), name: .myselfLoginInfoDidUpdate, object: nil)
    }
    
    func recieveMessageBoard() async {
        do {
            let data: Data = try await requestDataQuery(for: .messageBoard, using: PalaceDefinitions.MessageBoardCommands.retrieve.rawValue)
            messageBoardItems = try JSONDecoder().decode(PalaceDefinitions.MessageBoardResponse.self, from: data).items
            print(messageBoardItems)
        } catch {
            print(error)
        }
    }
    
    func uploadMessageBoard(message: String) async {
        struct CustomQuery: PalaceRequestQueryBase {
            var authenticateToken: String?
            var message: String?
        }
        
        do {
            let data: Data = try await requestDataQuery(for: .messageBoard, using: PalaceDefinitions.MessageBoardCommands.upload.rawValue, query: CustomQuery(message: message))
            messageBoardItems = try JSONDecoder().decode(PalaceDefinitions.MessageBoardResponse.self, from: data).items
            print(messageBoardItems)
        } catch {
            print(error)
        }
    }
    
    @objc private func updatePalaceCredentials(_ notification: NSNotification) {
        guard let myselfUserInformation = notification.object as? MyselfDefinitions.UserInformation? else {
            return
        }
        if let myselfUserInformation, let userId = myselfUserInformation.userId, let userName = myselfUserInformation.userName {
            palaceCredentials = .init(userName: userName, userId: userId)
        } else {
            palaceCredentials = nil
        }
    }
}


extension CurrentPalaceSession {
    
    private func getURLRequest(urlQuery: URL, headerData: Data) -> URLRequest {
        var request = URLRequest(url: urlQuery, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = headerData
        return request
    }
    
    private func requestDataQuery(for queryLocation: PalaceDefinitions.QueryLocations, using specifiedMethod: String = "", query specifiedQuery: PalaceRequestQueryBase? = nil) async throws -> Data {
        
        // Create new request query to send along with the request following "RequestQueryBase" protocol
        var requestQuery = specifiedQuery ?? {
            struct DefaultQuery: PalaceRequestQueryBase, Codable {
                var authenticateToken: String?
            }
            return DefaultQuery()
        }()
        
        // Get app token and set into requestQuery from stored variable if current category is present, otherwise request a new one immediately.
        requestQuery.authenticateToken = authenticateToken != nil ? authenticateToken?.uuidString : try await requestAuthenticateToken()?.uuidString
        
        // Encode requestQuery into data
        let requestData = try JSONEncoder().encode(requestQuery)
        
        // Get URL object
        let urlWithQuery: URL = {
            var url: URL = queryLocation.getUrl()
            url.append(queryItems: [.init(name: "method", value: specifiedMethod)])
            return url
        }()
        
        // Get URLRequest object
        let request = getURLRequest(urlQuery: urlWithQuery, headerData: requestData)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("Query response: \(String(data: data, encoding: .utf8))")
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
    
    @discardableResult
    private func requestAuthenticateToken() async throws -> UUID? {
        
        do {
            // Create a JSON object that will be posted to the server later.
            let credentialData = try JSONEncoder().encode(palaceCredentials)
            
            // Create a HTTPS POST Request
            let request: URLRequest = {
                var req = URLRequest(url: PalaceDefinitions.PortalLocations.auth, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpMethod = "POST"
                req.httpBody = credentialData
                return req
            }()
            
            // Send request to server
            let (data, _) = try await URLSession.shared.data(for: request)
            print("Auth return: \(String(data: data, encoding: .utf8))")
            
            authenticateToken = UUID(uuidString: String(data: data, encoding: .utf8) ?? "")
            
            print("Dictionary Token: \(authenticateToken?.uuidString ?? "-")")
            
            return authenticateToken
        } catch {
            print("\((error as NSError).code)")
            throw error
        }
    }
}
