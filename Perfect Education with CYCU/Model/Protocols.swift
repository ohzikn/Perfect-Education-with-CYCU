//
//  Protocols.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/19.
//

import Foundation

// Protocol data structure for minimum data to send along with http request
protocol RequestQueryBase: Codable {
    var APP_AUTH_token: String? { get set }
}
