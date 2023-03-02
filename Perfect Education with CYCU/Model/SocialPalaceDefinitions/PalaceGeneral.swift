//
//  General.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/3/3.
//

import Foundation

struct PalaceDefinitions {
    
    struct PortalLocations {
        static let root: URL! = URL(string: "https://zyozi.jp")
        static let auth: URL = root.appending(path: "/authenticate")
    }
    
    enum QueryLocations: String {
        case messageBoard = "/messageBoard"
        
        func getUrl() -> URL {
            PortalLocations.root.appending(path: self.rawValue)
        }
    }
    
    struct Credentials: Codable {
        let userName: String
        let userId: String
    }
    
    enum MessageBoardCommands: String, CaseIterable {
        case recieve
        case upload
    }
    
    struct MessageBoardResponse: Codable {
        let items: [MessageBoardItem]
    }
    
    struct MessageBoardItem: Codable, Identifiable {
        let id: UUID = UUID()
        let userName: String?
        let userId: String?
        let message: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, userName, userId, message
        }
    }
}
