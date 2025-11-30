import Foundation

protocol ArtworkRepositoryProtocol {
    func fetchArtworks(page: Int, limit: Int) async throws -> PaginatedResponse<Artwork>
    func searchArtworks(query: String, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork>
    func filterArtworksByYear(startYear: Int?, endYear: Int?, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork>
    func fetchArtworkDetail(id: Int) async throws -> Artwork
    func fetchArtworksByArtist(artistId: Int, excludeArtworkId: Int, limit: Int) async throws -> [Artwork]
}
