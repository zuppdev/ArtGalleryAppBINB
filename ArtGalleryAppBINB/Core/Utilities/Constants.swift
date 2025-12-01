import Foundation

struct APIConstants {
    static let baseURL = "https://api.artic.edu/api/v1"
    static let cdnURL = "https://lakeimagesweb.artic.edu/iiif/2"
    static let officialIIIFURL = "https://www.artic.edu/iiif/2"
}

struct ImageConstants {
    static let thumbnailSize = "200"
    static let mediumSize = "843"
    static let largeSize = "1686"
}

struct AppConstants {
    static let defaultPageLimit = 20
    static let maxCacheImages = 100
}
