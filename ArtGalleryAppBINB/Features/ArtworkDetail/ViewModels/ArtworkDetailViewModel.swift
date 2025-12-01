import Foundation
import UIKit
import Photos

@MainActor
class ArtworkDetailViewModel: ObservableObject {
    @Published var artwork: ArtworkDetail?
    @Published var relatedArtworks: [ArtworkSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = ArtworkAPIService.shared
    private let imageService = ImageService.shared
    
    // Story 4: Load detail
    func loadArtwork(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            artwork = try await apiService.fetchArtworkDetail(id: id)
            
            // Story 5: Load related artworks from same artist
            if let artistId = artwork?.artistId {
                await loadRelatedArtworks(artistId: artistId)
            }
        } catch {
            errorMessage = "Failed to load artwork details"
        }
        
        isLoading = false
    }
    
    // Story 5: Load artworks by artist
    private func loadRelatedArtworks(artistId: Int) async {
        do {
            let response = try await apiService.fetchArtworksByArtist(artistId: artistId, limit: 10)
            relatedArtworks = response.data.filter { $0.id != artwork?.id }
        } catch {
            print("Failed to load related artworks")
        }
    }
    
    // Story 6: Download image
    func downloadImage() async -> Bool {
        guard let imageId = artwork?.imageId else { return false }
        
        do {
            let imageData = try await imageService.downloadFullResolutionImage(imageId: imageId)
            
            guard let image = UIImage(data: imageData) else { return false }
            
            // Request photo library permission
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            
            guard status == .authorized else {
                errorMessage = "Photo library access denied"
                return false
            }
            
            // Save to photo library
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            
            return true
        } catch {
            errorMessage = "Failed to download image"
            return false
        }
    }
}
