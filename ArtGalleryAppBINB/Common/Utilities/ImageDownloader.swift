//
//  ImageDownloader.swift
//  ArtGallery
//
//  Image downloading utility with caching
//

import UIKit

final class ImageDownloader {
    static let shared = ImageDownloader()
    
    private let cache = ImageCache.shared
    private var activeTasks: [String: Task<UIImage?, Never>] = [:]
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
    }
    
    @MainActor
    func downloadImage(from url: URL) async -> UIImage? {
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = cache.getImage(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check if there's already an active task for this URL
        if let existingTask = activeTasks[cacheKey] {
            return await existingTask.value
        }
        
        // Create new download task
        let task = Task<UIImage?, Never> { @MainActor in
            do {
                let (data, _) = try await session.data(from: url)
                
                guard let image = UIImage(data: data) else {
                    activeTasks.removeValue(forKey: cacheKey)
                    return nil
                }
                
                // Cache the image
                cache.setImage(image, forKey: cacheKey)
                activeTasks.removeValue(forKey: cacheKey)
                
                return image
            } catch {
                print("Image download failed: \(error.localizedDescription)")
                activeTasks.removeValue(forKey: cacheKey)
                return nil
            }
        }
        
        activeTasks[cacheKey] = task
        return await task.value
    }
    
    func cancelDownload(for url: URL) {
        let cacheKey = url.absoluteString
        activeTasks[cacheKey]?.cancel()
        activeTasks.removeValue(forKey: cacheKey)
    }
}
