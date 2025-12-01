import Foundation

struct ArtworkDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let imageId: String?
    let artistId: Int?
    let description: String?
    let dimensions: String?
    let mediumDisplay: String?
    let isPublicDomain: Bool?
    let altImageIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, dimensions
        case artistDisplay = "artist_display"
        case dateDisplay = "date_display"
        case imageId = "image_id"
        case artistId = "artist_id"
        case mediumDisplay = "medium_display"
        case isPublicDomain = "is_public_domain"
        case altImageIds = "alt_image_ids"
    }
}
