import Foundation

@MainActor
class ArtworkDetailViewModel: ObservableObject {
    @Published var artwork: Artwork?
    @Published var relatedArtworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let artworkId: Int
    private let repository: ArtworkRepositoryProtocol

    init(artworkId: Int, repository: ArtworkRepositoryProtocol) {
        self.artworkId = artworkId
        self.repository = repository
    }

    func loadArtworkDetail() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                let fetchedArtwork = try await repository.fetchArtworkDetail(id: artworkId)
                artwork = fetchedArtwork

                if let artistId = fetchedArtwork.artistId {
                    await loadRelatedArtworks(artistId: artistId)
                }
            } catch {
                errorMessage = handleError(error)
            }

            isLoading = false
        }
    }

    private func loadRelatedArtworks(artistId: Int) async {
        do {
            let artworks = try await repository.fetchArtworksByArtist(artistId: artistId, excludeArtworkId: artworkId, limit: 10)
            relatedArtworks = artworks
        } catch {
            print("Failed to load related artworks: \(error)")
        }
    }

    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription ?? "An error occurred"
        }
        return error.localizedDescription
    }
}
