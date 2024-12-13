//
//  SharedItem.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-12.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class SharedItem {
    var id: UUID
    var content: Data?  // Store the serialized content as Data
    var timestamp: Date
    
    // Custom initializer
    init(id: UUID = UUID(), content: SharedContent? = nil, timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
        if let content = content {
            self.content = try? JSONEncoder().encode(content) // Encode the SharedContent to Data
        }
    }
    
    // Decode the content when needed
    func decodedContent() -> SharedContent? {
        guard let contentData = content else { return nil }
        return try? JSONDecoder().decode(SharedContent.self, from: contentData)
    }
}


enum SharedContent: Codable {
    case text(String)
    case image(Data)
    case url(URL)

    enum CodingKeys: String, CodingKey {
        case type, value
    }

    // Custom encoding logic
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .value)
        case .image(let imageData):
            try container.encode("image", forKey: .type)
            try container.encode(imageData, forKey: .value)
        case .url(let url):
            try container.encode("url", forKey: .type)
            try container.encode(url, forKey: .value)
        }
    }

    // Custom decoding logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let value = try container.decode(String.self, forKey: .value)
            self = .text(value)
        case "image":
            let value = try container.decode(Data.self, forKey: .value)
            self = .image(value)
        case "url":
            let value = try container.decode(URL.self, forKey: .value)
            self = .url(value)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
}
