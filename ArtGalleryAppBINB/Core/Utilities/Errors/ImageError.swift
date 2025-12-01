import Foundation

enum ImageError: Error, LocalizedError {
    case invalidURL
    case downloadFailed
    case invalidImageData
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .downloadFailed:
            return "Failed to download image"
        case .invalidImageData:
            return "Invalid image data"
        case .saveFailed:
            return "Failed to save image"
        }
    }
}
