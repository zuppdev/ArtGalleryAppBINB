//
//  ArtworkRepositoryProtocol.swift
//  ArtGallery
//
//  Repository protocol for artwork data access
//

import Foundation

protocol ArtworkRepositoryProtocol {
    func fetchArtworks(page: Int, limit: Int) async throws -> PaginatedResponse<Artwork>
    func searchArtworks(query: String, page: Int, limit: Int) async throws -> PaginatedResponse<Artwork>
    func fetchArtworkDetail(id: Int) async throws -> Artwork
    func fetchArtworksByArtist(artistName: String, excludeId: Int, limit: Int) async throws -> [Artwork]
}
