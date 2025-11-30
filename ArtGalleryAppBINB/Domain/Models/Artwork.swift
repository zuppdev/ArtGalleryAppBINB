import Foundation

struct Artwork: Equatable {
    let id: Int
    let title: String
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

    var imageUrl: String? {
        guard let imageId = imageId else { return nil }
        return "https://www.artic.edu/iiif/2/\(imageId)/full/843,/0/default.jpg"
    }

    var thumbnailUrl: String? {
        guard let imageId = imageId else { return nil }
        return "https://www.artic.edu/iiif/2/\(imageId)/full/200,/0/default.jpg"
    }

    var fullImageUrl: String? {
        guard let imageId = imageId else { return nil }
        return "https://www.artic.edu/iiif/2/\(imageId)/full/full/0/default.jpg"
    }
}
