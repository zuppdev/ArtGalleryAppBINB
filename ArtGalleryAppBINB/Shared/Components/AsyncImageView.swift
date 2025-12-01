import SwiftUI

struct AsyncImageView: View {
    let imageId: String?
    let size: ImageSize
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadFailed = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let imageId = imageId else {
            isLoading = false
            loadFailed = true
            return
        }
        
        do {
            image = try await ImageService.shared.loadImage(imageId: imageId, size: size)
            loadFailed = false
        } catch {
            print("⚠️ Failed to load \(size.rawValue)px image for \(imageId): \(error)")
            loadFailed = true
        }
        
        isLoading = false
    }
}
