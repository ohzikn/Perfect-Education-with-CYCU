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
        
        // Get related authentication location
        func getRelatedAuthenticateLocation() -> String {
            switch self {
            case .base:
                return AuthenticateLocations.base.rawValue
            case .workStudy:
                return AuthenticateLocations.workStudy.rawValue
            case .credits:
                return AuthenticateLocations.credits.rawValue
            }
        }
        
        func getUrl() -> URL {
            return PortalLocations.auth.appending(path: self.rawValue)
        }
    }
    
    // Declared as private to prevent direct access from other structs or classes
    private enum AuthenticateLocations: String {
        case base = "/home/json/ss_loginUser.jsp"
        case election = "/elective/mvc/elective_system.jsp"
        case workStudy = "/Hire_workStudy/json/ss_loginUser.jsp"
        case credits = "/credit/json/ss_loginUser.jsp"
    }
    
    struct UserInformation: Codable {
        let userId: String?
        let userName: String?
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
    
    // MARK: Authenticate
    struct AuthenticateInformation: Codable {
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
    
    // MARK: WorkStudy
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
    
    // MARK: Credits
    struct CreditsInformation: Codable {
        let stdTotalCredits: Int?
        let stdRealTotalCredits: Int?
        let stdFreeCredits: Int?
        let yearTerm: String?
        let stdEnglishPass: Bool?
        let stdRequiresCredits: Int?
        let stdElectiveCredits: Int?
        let stdBasicCredits: Int?
        
        let stdIdentity: [StdIdentity]?
        struct StdIdentity: Codable, Identifiable {
            let id = UUID()
            let stdId: String?
            let subShort: String?
            let subName: String?
            
            private enum CodingKeys: String, CodingKey {
                case stdId = "SUB1_ID"
                case subShort = "SUB1_SUB"
                case subName = "SUB1_SUB_NAME"
            }
        }
        
        let stdCourseList: [StdCourse]?
        struct StdCourse: Codable, Identifiable, Hashable {
            let id = UUID()
            let subjectName: String?
            let studyClass: String?
            let opCreditA: Int?
            let pKind: String?
            let passYearTerm: String?
            let opQualityA: String?
            let remoteYearTerm: String?
            let termA: String?
            let moocsYearTerm: String?
            let crossYearTerm: String?
            let pblYearTerm: String?
            let pKindName: String?
            let scoreFinal: String?
            let subjectCode: String?
            let miniatureYearTerm: String?
            let moocs2YearTerm: String?
            let courseName: String?
            let programYearTerm: String?
            let courseCode: String?
            let employmentYearTerm: String?
            let opCreditM: String?
            
            private enum CodingKeys: String, CodingKey {
                case subjectName = "CURS_NM_C_S_M"
                case studyClass = "STDY_CLASS"
                case opCreditA = "OP_CREDIT_A"
                case pKind = "P_KIND"
                case passYearTerm = "PASS_YEARTERM"
                case opQualityA = "OP_QUALITY_A"
                case remoteYearTerm = "REMOTE_YEAR_TERM"
                case termA = "TERM_A"
                case moocsYearTerm = "MOOCS_YEAR_TERM"
                case crossYearTerm = "CROSS_YEAR_TERM"
                case pblYearTerm = "PBL_YEAR_TERM"
                case pKindName = "P_KIND_NAME"
                case scoreFinal = "SCORE_FNAL"
                case subjectCode = "CURS_CODE_M"
                case miniatureYearTerm = "MINIATURE_YEAR_TERM"
                case moocs2YearTerm = "MOOCS2_YEAR_TERM"
                case courseName = "CURS_NM_C_S_A"
                case programYearTerm = "PROGRAM_YEAR_TERM"
                case courseCode = "OP_CODE_A"
                case employmentYearTerm = "EMPLOYMENT_YEAR_TERM"
                case opCreditM = "OP_CREDIT_M"
            }
        }
        
        let stdFullEnglish: [StdFullEnglish]?
        struct StdFullEnglish: Codable, Identifiable {
            let id = UUID()
            let opCode: String?
            let opCredit: String?
            let yearTerm: String?
            let courseName: String?
            let scoreFinal: String?
            
            private enum CodingKeys: String, CodingKey {
                case opCode = "OP_CODE"
                case opCredit = "OP_CREDIT"
                case yearTerm = "YEAR_TERM"
                case courseName = "CURS_NM_C_S"
                case scoreFinal = "SCORE_FNAL"
            }
        }
        
        let stdInfo: StdInfo?
        struct StdInfo: Codable {
            let userName: String?
            let userId: String?
            let departmentCode: String?
            let departmentGradeName: String?
            let typeName: String?
            
            private enum CodingKeys: String, CodingKey {
                case userName = "STMD1_NAME"
                case userId = "STMD3_ID"
                case departmentCode = "STMD3_CUR_DPT"
                case departmentGradeName = "DEPT_ABVI_C"
                case typeName = "TYPE_NAME"
            }
        }
        
        let yearTermList: [YearTermList]?
        struct YearTermList: Codable, Identifiable {
            let id = UUID()
            let yearName: Int?
            let termName: String?
            let yearTerm: Int?
            
            private enum CodingKeys: String, CodingKey {
                case yearName = "YEAR_NAME"
                case termName = "TERM_NAME"
                case yearTerm = "YEAR_TERM"
            }
        }
        
        let exceptionGeCreditsList: [ExceptionGeCreditsList]?
        struct ExceptionGeCreditsList: Codable, Identifiable {
            let id = UUID()
            let departmentCode: String?
            
            private enum CodingKeys: String, CodingKey {
                case departmentCode = "DEPT_CODE"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case stdTotalCredits = "STD_TOTAL_CREDITS"
            case stdRealTotalCredits = "STD_REAL_TOTAL_CREDITS"
            case stdFreeCredits = "STD_FREE_CREDITS"
            case yearTerm = "YEAR_TERM"
            case stdEnglishPass = "STD_ENGLISH_PASS"
            case stdRequiresCredits = "STD_REQUIRED_CREDITS"
            case stdElectiveCredits = "STD_ELECTIVE_CREDITS"
            case stdBasicCredits = "STD_BASIC_CREDITS"
            case stdIdentity = "STD_IDENTITY"
            case stdCourseList = "STD_COURSE_LIST"
            case stdFullEnglish = "STD_FULL_ENGLISH"
            case stdInfo = "STD_INFO"
            case yearTermList = "YEAR_TERM_LIST"
            case exceptionGeCreditsList = "exception_GECredits_LIST"
        }
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
