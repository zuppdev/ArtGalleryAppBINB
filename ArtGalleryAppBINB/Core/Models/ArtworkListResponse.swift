import Foundation

struct ArtworkListResponse: Codable {
    let pagination: Pagination
    let data: [ArtworkSummary]
    let config: APIConfig
}
