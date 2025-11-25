//
//  ArtworkRepository.swift
//  ArtGallery
//
//  Repository implementation for artwork data
//

import Foundation

final class ArtworkRepository: ArtworkRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchArtworks(page: Int, limit: Int) async throws -> PaginatedResponse<Artwork> {
        let response: ArtworkListResponse = try await apiClient.request(.artworks(page: page, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return PaginatedResponse(data: artworks, pagination: response.pagination)
    }
    
    func searchArtworks(query: String, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork> {
        let response: ArtworkSearchResponse = try await apiClient.request(.searchArtworks(query: query, page: page, limit: limit))
        let artworks = response.data.map { $0.toDomain() }
        return PaginatedResponse(data: artworks, pagination: response.pagination)
    }
    
    func fetchArtworkDetail(id: Int) async throws -> Artwork {
        let response: ArtworkDetailResponse = try await apiClient.request(.artworkDetail(id: id))
        return response.data.toDomain()
    }
    
    func fetchArtworksByArtist(artistName: String, excludeId: Int, limit: Int) async throws -> [Artwork] {
        let response: ArtworkSearchResponse = try await apiClient.request(.searchByArtist(artistName: artistName, limit: limit))
        let artworks = response.data
            .map { $0.toDomain() }
            .filter { $0.id != excludeId }
        return artworks
    }
}
