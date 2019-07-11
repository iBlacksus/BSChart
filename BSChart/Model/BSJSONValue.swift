//
//  JSONValue.swift
//  BSChart
//
//  Created by iBlacksus on 3/12/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

public enum BSJSONValue: Decodable {
    case string(String)
    case int(Int)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(BSJSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unavailable type"))
        }
    }
    
    public func get() -> Any {
        switch self {
        case .int(let value):
            return value
        case .string(let value):
            return value
        }
    }
}
