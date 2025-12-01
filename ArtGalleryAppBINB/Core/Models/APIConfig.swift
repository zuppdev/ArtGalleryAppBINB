import Foundation

struct APIConfig: Codable {
    let iiifUrl: String
    let websiteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case iiifUrl = "iiif_url"
        case websiteUrl = "website_url"
    }
}
