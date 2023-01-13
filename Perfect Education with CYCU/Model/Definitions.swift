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
    }
    
    struct PortalLocations {
        // Commons
        static let root: URL! = URL(string: "https://myself.cycu.edu.tw")
        static let login: URL = root.appending(path: "/auth/myselfLogin")
//        static let auth: URL = root.appending(path: "/myself_api_127")
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
        
        static func getAuthenticationLocation(for request: AuthenticateLocations) -> URL {
            switch request {
            case .authRoot:
                return PortalLocations.root.appending(path: AuthenticateLocations.authRoot.rawValue)
            default:
                return PortalLocations.root.appending(path: AuthenticateLocations.authRoot.rawValue).appending(path: request.rawValue)
            }
        }
    }
    
    enum AuthenticateLocations: String {
        case authRoot = "/myself_api_127"
        case base = "/home/json/ss_loginUser.jsp"
        case election = "/elective/mvc/elective_system.jsp"
        case workStudy = "/Hire_workStudy/mvc/welcome.jsp"
    }
    
    enum ElectionCommands: String {
        case st_info_get
        case stage_control_get
        case st_base_info
        case track_get
        case st_record
        case ann_get
        case course_get
        case track_insert
        case track_del
        case take_course_and_register_insert
        case take_course_and_register_del
        case login_sys_upd
        case volunteer_set
        case col_checkbox_upd
    }
    
    struct SessionInformation: Codable {
        var APP_AUTH: AppAuth?
        var APP_AUTH_token: String?
        var auth_result: AuthResult?
        var login_YN: String?
        var loginUser_CNAME: String?
        var loginUser_IDCODE: String?
        var loginUser_TYPE: String?
        var loginToken: String?
        var userName: String?
        var userId: String?
        var deptNo: String?
        var deptName: String?
        var deviceInfo: DeviceInfo?
        
        struct AuthResult: Codable {
            var loginUser_test_TYPE: String?
            var loginUser_test_IDCODE: String?
            var done_YN: String?
            var APP_AUTH_token: String?
            var APP_AUTH: AppAuth?
        }
        
        struct DeviceInfo: Codable {
            var ip: String?
            var os: String?
            var platform: String?
            var browser: String?
            var isMobile: Bool?
            var isDesktop: Bool?
            var isBot: Bool?
            var Table_Responsive_class: String?
        }
        
        struct ApiInfo: Codable {
            var myself_api_url: String?
            var itouch_url: String?
            var api_url: String?
            var SERVER_NUMBER: String?
        }
        
        struct AppAuth: Codable {
            var idcode: String?
        }
    }
    
    
    
//    struct NavigationData: Codable, Identifiable {
//        let id = UUID()
//        var keyId: Int
//        var sectionNode: String?
//        var sectionName: String?
//        var group: [String]?
//        var items: [Item]?
//        struct Item: Codable, Identifiable {
//            let id = UUID()
//            var itemName: String?
//            var location: String?
////            struct thirdLayer: Codable { }
//            private enum CodingKeys: String, CodingKey {
//                case itemName = "secondName"
//                case location = "pageName"
//            }
//        }
//
//        private enum CodingKeys: String, CodingKey {
//            case keyId
//            case sectionNode = "paramName"
//            case sectionName = "firstLayer"
//            case group
//            case items = "secondLayer"
//        }
//    }
}
