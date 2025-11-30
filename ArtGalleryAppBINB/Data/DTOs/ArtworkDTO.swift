import Foundation

struct ArtworkResponseDTO: Decodable {
    let data: ArtworkDTO
}

struct ArtworkListResponseDTO: Decodable {
    let data: [ArtworkDTO]
    let pagination: PaginationDTO
}

struct ArtworkDTO: Decodable {
    let id: Int
    let title: String?
    let artistDisplay: String?
    let dateDisplay: String?
    let dateStart: Int?
    let dateEnd: Int?
    let placeOfOrigin: String?
    let dimensions: String?
    let mediumDisplay: String?
    let creditLine: String?
    let imageId: String?
    let artistId: Int?
    let artistTitle: String?
    let artworkTypeTitle: String?
    let departmentTitle: String?
    let categoryTitles: [String]?

    func toDomain() -> Artwork {
        return Artwork(
            id: id,
            title: title ?? "Untitled",
            artistDisplay: artistDisplay,
            dateDisplay: dateDisplay,
            dateStart: dateStart,
            dateEnd: dateEnd,
            placeOfOrigin: placeOfOrigin,
            dimensions: dimensions,
            mediumDisplay: mediumDisplay,
            creditLine: creditLine,
            imageId: imageId,
            artistId: artistId,
            artistTitle: artistTitle,
            artworkTypeTitle: artworkTypeTitle,
            departmentTitle: departmentTitle,
            categoryTitles: categoryTitles
        )
    }
}

struct PaginationDTO: Decodable {
    let total: Int
    let limit: Int
    let currentPage: Int
    let totalPages: Int

    func toDomain() -> Pagination {
        return Pagination(
            total: total,
            limit: limit,
            currentPage: currentPage,
            totalPages: totalPages
        )
    }
}
