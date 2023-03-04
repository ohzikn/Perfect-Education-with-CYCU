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
    
    enum LessonListCommands: String, CaseIterable {
        case recieve
        case upload
    }
    
    struct LessonList: Codable {
        let items: [LessonInformation]
        
        struct LessonInformation: Codable, Identifiable {
            let id = UUID()
            
            let allEnglish: Int?  // 全英語授課
            let courseCode: String? // 課程代碼
            let courseName: String?  // 課程名稱
            let crossName: String? // 學程名稱
            let crossType: String? // 學程類別
            let departmentCode: String? // 學系班級代碼
            let departmentName: String?  // 學系班級名稱
            let distanceCourse: Int? // 遠距課程
            let mgDepartmantCode: String? // 學系代碼
            let moocs: Int? // 微學分課程
            let nonStop: Int? // 可否停修
            let notes: String? // 備注
            let openCode: String? // 開課代碼
            let openCredit: Int? // 學分
            let opQuality: String? // 全/半
            let opRmName1: String? // 上課教室1
            let opRmName2: String? // 上課教室2
            let opRmName123: String? // 上課教室（全部）
            let opStdy: String? // 必/選修
            let opTime1: String? // 上課時間1
            let opTime2: String? // 上課教室2
            let opTime123: String? // 上課時間（全部）
            let opType: String? // 通識類別
            let teacher: String? // 授課老師
            
            private enum CodingKeys: String, CodingKey {
                case allEnglish, courseCode, courseName, crossName, crossType, departmentCode, departmentName, distanceCourse, mgDepartmantCode, moocs, nonStop, notes, openCode, openCredit, opQuality, opRmName1, opRmName2, opRmName123, opStdy, opTime1, opTime2, opTime123, opType, teacher
            }
        }
    }
}
