//
//  Extensions.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/17.
//

import Foundation

extension UserDefaults {
    enum toggleKeyValues: String {
        case usesFaceId
    }
}

extension Date {
    func getString(customFormat: String? = nil) -> String? {
        let formatter = DateFormatter()
        // If no custom format is specified, use default formatter from JSON structure.]
        formatter.dateFormat = customFormat != nil ? customFormat : "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
}