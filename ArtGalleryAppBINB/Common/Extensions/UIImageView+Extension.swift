import UIKit

extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let urlString = urlString else {
            self.image = UIImage(systemName: "photo")
            return
        }

        Task {
            do {
                let image = try await ImageDownloader.shared.downloadImage(from: urlString)
                await MainActor.run {
                    self.image = image ?? UIImage(systemName: "photo")
                }
            } catch {
                await MainActor.run {
                    self.image = UIImage(systemName: "photo")
                }
            }
        }
    }

    func cancelImageLoad() {
        self.image = nil
    }
}
