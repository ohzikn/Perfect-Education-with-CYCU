//
//  PropertyWrappers.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/2/7.
//

import Foundation

@propertyWrapper
struct DecodeToInt: Codable, Equatable, Hashable {
    var wrappedValue: Int?
    
    init() {
        // Set wrappedValue to nil by default initializer
        self.wrappedValue = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            wrappedValue = value
        } else if let value = try? container.decode(String.self) {
            wrappedValue = Int(value)
        }
    }
    
    static func == (lhs: DecodeToInt, rhs: DecodeToInt) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

@propertyWrapper
struct DecodeToIntArray: Codable, Equatable, Hashable {
    var wrappedValue: [Int]?
    
    init() {
        // Set wrappedValue to nil by default initializer
        self.wrappedValue = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            wrappedValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789,").inverted).components(separatedBy: ",").map({ Int($0) ?? -1 })
        }
    }
    
    static func == (lhs: DecodeToIntArray, rhs: DecodeToIntArray) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

@propertyWrapper
struct DecodeToDate: Codable, Equatable, Hashable {
    var wrappedValue: Date?
    
    init() {
        // Set wrappedValue to nil by default initializer
        self.wrappedValue = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            wrappedValue = formatter.date(from: value)
        }
    }
    
    static func == (lhs: DecodeToDate, rhs: DecodeToDate) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

@propertyWrapper
struct DecodeToStringAndRemoveTrailingSpaces: Codable, Equatable, Hashable {
    var wrappedValue: String?
    
    init() {
        // Set wrappedValue to nil by default initializer
        self.wrappedValue = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if var value = try? container.decode(String.self) {
            while value.last?.isWhitespace == true { value.removeLast() }
            wrappedValue = value
        }
    }
    
    static func == (lhs: DecodeToStringAndRemoveTrailingSpaces, rhs: DecodeToStringAndRemoveTrailingSpaces) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
