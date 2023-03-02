//
//  Authenticate.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/19.
//

import Foundation

extension MyselfDefinitions {
    // MARK: Data structure
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
}
