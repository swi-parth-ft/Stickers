import SwiftData
import Foundation

@Model
class SharedItem {
    var id: UUID
    var content: Data?
    var timestamp: Date
    var caption: String?
    
    init(id: UUID = UUID(), content: SharedContent? = nil, timestamp: Date = Date(), caption: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.caption = caption
        if let content = content {
            self.content = try? JSONEncoder().encode(content)
        }
    }
    
    func decodedContent() -> SharedContent? {
        guard let contentData = content else { return nil }
        return try? JSONDecoder().decode(SharedContent.self, from: contentData)
    }
}

enum SharedContent: Codable {
    case text(String)
    case imageURL(URL)
    case url(URL)
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .value)
        case .imageURL(let imageURL):
            try container.encode("imageURL", forKey: .type)
            try container.encode(imageURL, forKey: .value)
        case .url(let url):
            try container.encode("url", forKey: .type)
            try container.encode(url, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let value = try container.decode(String.self, forKey: .value)
            self = .text(value)
        case "imageURL":
            let value = try container.decode(URL.self, forKey: .value)
            self = .imageURL(value)
        case "url":
            let value = try container.decode(URL.self, forKey: .value)
            self = .url(value)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
}
