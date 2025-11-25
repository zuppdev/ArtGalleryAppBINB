//
//  UIImageView+Extension.swift
//  ArtGallery
//
//  UIImageView extension for image loading
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = UIImage(systemName: "photo")) {
        self.image = placeholder
        
        guard let url = url else { return }
        
        Task { @MainActor in
            if let image = await ImageDownloader.shared.downloadImage(from: url) {
                UIView.transition(with: self,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                    self.image = image
                })
            }
        }
    }
    
    func cancelImageLoad() {
        guard let url = self.image?.accessibilityIdentifier,
              let imageURL = URL(string: url) else { return }
        ImageDownloader.shared.cancelDownload(for: imageURL)
    }
}
