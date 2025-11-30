import Foundation

class ArtworkRepository: ArtworkRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchArtworks(page: Int, limit: Int) async throws -> PaginatedResponse<Artwork> {
        let response: ArtworkListResponseDTO = try await apiClient.request(.artworks(page: page, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return PaginatedResponse(data: artworks, pagination: response.pagination.toDomain())
    }

    func searchArtworks(query: String, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork> {
        let response: ArtworkListResponseDTO = try await apiClient.request(.search(query: query, page: page, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return PaginatedResponse(data: artworks, pagination: response.pagination.toDomain())
    }

    func filterArtworksByYear(startYear: Int?, endYear: Int?, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork> {
        let response: ArtworkListResponseDTO = try await apiClient.request(.filterByYear(startYear: startYear, endYear: endYear, page: page, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return PaginatedResponse(data: artworks, pagination: response.pagination.toDomain())
    }

    func fetchArtworkDetail(id: Int) async throws -> Artwork {
        let response: ArtworkResponseDTO = try await apiClient.request(.artworkDetail(id: id))
        return response.data.toDomain()
    }

    func fetchArtworksByArtist(artistId: Int, excludeArtworkId: Int, limit: Int) async throws -> [Artwork] {
        let response: ArtworkListResponseDTO = try await apiClient.request(.artworksByArtist(artistId: artistId, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return artworks.filter { $0.id != excludeArtworkId }
    }
}
