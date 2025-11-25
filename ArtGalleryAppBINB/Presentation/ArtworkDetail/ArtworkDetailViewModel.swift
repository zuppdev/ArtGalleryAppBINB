//
//  ArtworkDetailViewModel.swift
//  ArtGallery
//
//  ViewModel for artwork detail screen
//

import Foundation

@MainActor
final class ArtworkDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var artwork: Artwork?
    @Published var relatedArtworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoadingRelated = false
    
    // MARK: - Private Properties
    private let repository: ArtworkRepositoryProtocol
    private let artworkId: Int
    
    // MARK: - Initialization
    init(artworkId: Int, repository: ArtworkRepositoryProtocol = ArtworkRepository()) {
        self.artworkId = artworkId
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func loadArtworkDetail() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                artwork = try await repository.fetchArtworkDetail(id: artworkId)
                
                // Load related artworks
                if let artistName = artwork?.artistName, !artistName.isEmpty {
                    await loadRelatedArtworks(artistName: artistName)
                }
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    func retry() {
        loadArtworkDetail()
    }
    
    // MARK: - Private Methods
    private func loadRelatedArtworks(artistName: String) async {
        isLoadingRelated = true
        
        do {
            relatedArtworks = try await repository.fetchArtworksByArtist(
                artistName: artistName,
                excludeId: artworkId,
                limit: 10
            )
        } catch {
            print("Failed to load related artworks: \(error.localizedDescription)")
            // Don't show error for related artworks, just fail silently
        }
        
        isLoadingRelated = false
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
