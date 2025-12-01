import Foundation

struct ArtworkSummary: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let imageId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case artistDisplay = "artist_display"
        case dateDisplay = "date_display"
        case imageId = "image_id"
    }
}
