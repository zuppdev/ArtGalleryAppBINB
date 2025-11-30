import UIKit

actor ImageDownloader {
    static let shared = ImageDownloader()

    private var ongoingDownloads: [String: Task<UIImage?, Error>] = [:]

    private init() {}

    func downloadImage(from urlString: String) async throws -> UIImage? {
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            return cachedImage
        }

        if let ongoingTask = ongoingDownloads[urlString] {
            return try await ongoingTask.value
        }

        let task = Task<UIImage?, Error> {
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }

            guard let image = UIImage(data: data) else {
                throw NetworkError.noData
            }

            ImageCache.shared.setImage(image, forKey: urlString)
            return image
        }

        ongoingDownloads[urlString] = task

        defer {
            Task { await removeOngoingDownload(for: urlString) }
        }

        return try await task.value
    }

    private func removeOngoingDownload(for url: String) {
        ongoingDownloads.removeValue(forKey: url)
    }
}
