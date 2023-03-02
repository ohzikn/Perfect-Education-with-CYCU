//
//  Extensions.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/17.
//

import Foundation
import SwiftUI

extension UserDefaults {
    enum toggleKeyValues: String {
        case isFirstLaunch
        case usesFaceId
        case isExtendedPersonalDataUseAuthorized
    }
}

extension Notification.Name {
    static let searchResultDidUpdate = Notification.Name("SearchResultDidUpdate")
    static let courseListDidUpdate = Notification.Name("CourseListDidUpdate")
}

extension Date {
    func getString(customFormat: String? = nil) -> String? {
        let formatter = DateFormatter()
        // If no custom format is specified, use default formatter from JSON structure.]
        formatter.dateFormat = customFormat != nil ? customFormat : "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: DecodeToInt.Type, forKey key: K) throws -> DecodeToInt {
        if let value = try self.decodeIfPresent(type, forKey: key) { return value }
        return DecodeToInt()
    }
    
    func decode(_ type: DecodeToIntArray.Type, forKey key: K) throws -> DecodeToIntArray {
        if let value = try self.decodeIfPresent(type, forKey: key) { return value }
        return DecodeToIntArray()
    }
    
    func decode(_ type: DecodeToDate.Type, forKey key: K) throws -> DecodeToDate {
        if let value = try self.decodeIfPresent(type, forKey: key) { return value }
        return DecodeToDate()
    }
    
    func decode(_ type: DecodeToStringAndRemoveTrailingSpaces.Type, forKey key: K) throws -> DecodeToStringAndRemoveTrailingSpaces {
        if let value = try self.decodeIfPresent(type, forKey: key) { return value }
        return DecodeToStringAndRemoveTrailingSpaces()
    }
}
