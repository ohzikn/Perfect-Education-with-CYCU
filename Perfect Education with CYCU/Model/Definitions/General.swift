//
//  Defenitions.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/11.
//

import Foundation

struct Definitions {
    
    struct ExternalLocations {
        static let passwordReset: URL! = URL(string: "https://itouch.cycu.edu.tw/active_system/login/login_board.jsp")
        static let syllabus: URL! = URL(string: "https://cmap.cycu.edu.tw:8443/Syllabus/CoursePreview.html")
    }
    
    struct PortalLocations {
        // Commons
        static let root: URL! = URL(string: "https://myself.cycu.edu.tw")
        static let login: URL = root.appending(path: "/auth/myselfLogin")
        static let auth: URL = root.appending(path: "/myself_api_127")
        static let baseInfo: URL = root.appending(path: "baseInfo")
        // Requests
//        static let baseApi: URL = auth.appending(path: "/home/json/ss_loginUser.jsp")
//        static let electionApi: URL = auth.appending(path: "/elective/mvc/elective_system.jsp")
//        static let workStudy: URL = auth.appending(path: "/Hire_workStudy/mvc/welcome.jsp")
        
        
//        static let getNavData: URL! = URL(string: "/common/getNavData", relativeTo: base)
        
        
//        // Nodes
//        static private let _life: URL! = URL(string: "/life", relativeTo: base)
//        static private let _health: URL! = URL(string: "/health", relativeTo: base)
//        // Navigations (Life)
//        static let workStudyHome: URL! = URL(string: "/workStudy/welcome", relativeTo: _life)
//        static let workStudyCheck: URL! = URL(string: "/schedule/welcome", relativeTo: _life)
//        static let mentor: URL! = URL(string: "/mentor", relativeTo: _life)
//        static let election: URL! = URL(string: "/elective_system", relativeTo: _life)
//        static let credit: URL! = URL(string: "/std_Credit", relativeTo: _life)
//        static let yearTermCredit: URL! = URL(string: "/std_YearTerm_Credit", relativeTo: _life)
//        // Navigations (Health)
//        static let healthReporting: URL! = URL(string: "/healthTracking", relativeTo: _health)
    }
    
    enum QueryLocations: String {
        case base = "" // No absolute address available
        case workStudy = "/Hire_workStudy/mvc/welcome.jsp"
        case credits = "/credit/api/api_credit.jsp"
        case election = "/elective/mvc/elective_system.jsp"
        
        // Get related authentication location
        func getRelatedAuthenticateLocation() -> String {
            switch self {
            case .base:
                return AuthenticateLocations.base.rawValue
            case .workStudy:
                return AuthenticateLocations.workStudy.rawValue
            case .credits:
                return AuthenticateLocations.credits.rawValue
            case .election:
                return AuthenticateLocations.election.rawValue
            }
        }
        
        func getUrl() -> URL {
            return PortalLocations.auth.appending(path: self.rawValue)
        }
    }
    
    // Declared as private to prevent accident direct access from other structs or classes
    private enum AuthenticateLocations: String {
        case base = "/home/json/ss_loginUser.jsp"
        case workStudy = "/Hire_workStudy/json/ss_loginUser.jsp"
        case credits = "/credit/json/ss_loginUser.jsp"
        case election = "/elective/json/ss_loginUser_student.jsp"
    }
    
    // Data structure for storing account name and password strings
    struct LoginCredentials: Codable {
        let username: String
        let password: String?
        
        private enum CodingKeys: String, CodingKey {
            case username = "UserNm"
            case password = "UserPasswd"
        }
    }
    
    struct UserInformation: Codable, Equatable {
        let userId: String?
        @DecodeToStringAndRemoveAllSpaces var userName: String?
        let userType: String?
        let connectionName: String?
        let endHostIp: String?
        let loginToken: String?
        let didLogIn: String?
        let didFinishProcess: String?
        
        private enum CodingKeys: String, CodingKey {
            case userId = "loginUser_IDCODE"
            case userName = "loginUser_CNAME"
            case userType = "loginUser_TYPE"
            case connectionName = "conn_name"
            case endHostIp
            case loginToken
            case didLogIn = "login_YN"
            case didFinishProcess = "done_YN"
        }
    }
    
    enum PartOfDay: String {
        case morning = "早安"
        case afternoon = "午安"
        case evening = "晚安"
        case night = "深夜好"
        
        func getHappyEmoji() -> String {
            switch self {
            case .morning:
                return "☺️"
            case .afternoon:
                return "🥰"
            case .evening:
                return "🥳"
            case .night:
                return "😈"
            }
        }
    }
    func getCurrentDayPart() -> PartOfDay {
        let currentHour = Calendar.current.component(.hour, from: Date())
        switch currentHour {
        case 22...23, 0...5:
            return .night
        case 6...11:
            return .morning
        case 12...16:
            return .afternoon
        case 17...21:
            return .evening
        default:
            return .morning
        }
    }
}
