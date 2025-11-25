//
//  ArtworkDTO.swift
//  ArtGallery
//
//  Data Transfer Objects for API responses
//

import Foundation

// MARK: - API Response Wrappers
struct ArtworkListResponse: Codable {
    let pagination: Pagination
    let data: [ArtworkDTO]
}

struct ArtworkDetailResponse: Codable {
    let data: ArtworkDTO
}

struct ArtworkSearchResponse: Codable {
    let pagination: Pagination
    let data: [ArtworkDTO]
}

// MARK: - Artwork DTO
struct ArtworkDTO: Codable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let dateStart: Int?
    let dateEnd: Int?
    let mediumDisplay: String?
    let dimensions: String?
    let creditLine: String?
    let departmentTitle: String?
    let artworkTypeTitle: String?
    let imageId: String?
    let description: String?
    let placeOfOrigin: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artistDisplay = "artist_display"
        case dateDisplay = "date_display"
        case dateStart = "date_start"
        case dateEnd = "date_end"
        case mediumDisplay = "medium_display"
        case dimensions
        case creditLine = "credit_line"
        case departmentTitle = "department_title"
        case artworkTypeTitle = "artwork_type_title"
        case imageId = "image_id"
        case description
        case placeOfOrigin = "place_of_origin"
    }
    
    // Convert DTO to Domain Model
    func toDomain() -> Artwork {
        Artwork(
            id: id,
            title: title,
            artistDisplay: artistDisplay,
            dateDisplay: dateDisplay,
            dateStart: dateStart,
            dateEnd: dateEnd,
            mediumDisplay: mediumDisplay,
            dimensions: dimensions,
            creditLine: creditLine,
            departmentTitle: departmentTitle,
            artworkTypeTitle: artworkTypeTitle,
            imageId: imageId,
            description: description,
            placeOfOrigin: placeOfOrigin
        )
    }
}
