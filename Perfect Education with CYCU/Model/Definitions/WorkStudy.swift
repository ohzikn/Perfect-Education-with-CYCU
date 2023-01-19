//
//  WorkStudy.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/19.
//

import Foundation

extension Definitions {
    // MARK: Data structure
        struct WorkStudyInformation: Codable {
            let remoteAddress: String?
            let xFowardedFor: String?
            let didFinishProcess: String?
            let hireData: [HireData]?
            
            struct HireData: Codable, Identifiable {
                let id: UUID = UUID()
                
                private enum CodingKeys: CodingKey {
                    
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case remoteAddress = "getRemoteAddr"
                case xFowardedFor = "x-forwarded-for"
                case didFinishProcess = "done_YN"
                case hireData
            }
        }
}
