import UIKit

enum ImageSize: String {
    case thumbnail = "200"
    case medium = "843"
    case large = "1686"
    
    var path: String {
        return "/full/\(rawValue),/0/default.jpg"
    }
}

class ImageService {
    static let shared = ImageService()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = AppConstants.maxCacheImages
    }
    
    func loadImage(imageId: String, size: ImageSize = .medium) async throws -> UIImage {
        // Check cache first
        let cacheKey = "\(imageId)-\(size.rawValue)" as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            print("📦 Using cached image for: \(imageId)")
            return cachedImage
        }
        
        print("⬇️ Downloading image: \(imageId) at size: \(size.rawValue)")
        
        // Try CDN first (faster, works)
        let cdnURL = "\(APIConstants.cdnURL)/\(imageId)\(size.path)"
        
        do {
            let image = try await downloadImage(from: cdnURL)
            cache.setObject(image, forKey: cacheKey)
            print("✅ Downloaded from CDN: \(imageId)")
            return image
        } catch {
            print("⚠️ CDN failed, trying official URL: \(error)")
            
            // Fallback to official URL
            let officialURL = "\(APIConstants.officialIIIFURL)/\(imageId)\(size.path)"
            let image = try await downloadImage(from: officialURL)
            cache.setObject(image, forKey: cacheKey)
            print("✅ Downloaded from official URL: \(imageId)")
            return image
        }
    }
    
    // Story 6: Download full resolution for saving
    func downloadFullResolutionImage(imageId: String) async throws -> Data {
        let url = "\(APIConstants.cdnURL)/\(imageId)/full/\(ImageConstants.largeSize),/0/default.jpg"
        
        guard let imageURL = URL(string: url) else {
            throw ImageError.invalidURL
        }
        
        var request = URLRequest(url: imageURL)
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageError.downloadFailed
        }
        
        return data
    }
    
    private func downloadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.addValue("image/jpeg,image/png,image/*", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15 // 15 second timeout
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageError.downloadFailed
        }
        
        print("📡 HTTP Status: \(httpResponse.statusCode) for \(urlString)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ImageError.downloadFailed
        }
        
        // Check if we got HTML instead of an image (Cloudflare block)
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
           contentType.contains("text/html") {
            print("❌ Received HTML instead of image (blocked)")
            throw ImageError.downloadFailed
        }
        
        guard let image = UIImage(data: data) else {
            print("❌ Failed to create UIImage from \(data.count) bytes")
            throw ImageError.invalidImageData
        }
        
        print("✅ Image created: \(image.size)")
        return image
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
