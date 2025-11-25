//
//  PaginatedResponse.swift
//  ArtGallery
//
//  Generic pagination model
//

import Foundation

struct PaginatedResponse<T> {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let totalPages: Int
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case total
        case limit
        case offset
        case totalPages = "total_pages"
        case currentPage = "current_page"
    }
}
