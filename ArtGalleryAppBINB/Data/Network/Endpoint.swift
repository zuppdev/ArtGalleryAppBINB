//
//  Endpoint.swift
//  ArtGallery
//
//  API endpoint definitions
//

import Foundation

enum Endpoint {
    case artworks(page: Int, limit: Int)
    case searchArtworks(query: String, page: Int, limit: Int)
    case artworkDetail(id: Int)
    case searchByArtist(artistName: String, limit: Int)
    
    private var baseURL: String {
        "https://api.artic.edu/api/v1"
    }
    
    private var path: String {
        switch self {
        case .artworks, .searchArtworks:
            return "/artworks"
        case .artworkDetail(let id):
            return "/artworks/\(id)"
        case .searchByArtist:
            return "/artworks/search"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        switch self {
        case .artworks(let page, let limit):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            items.append(URLQueryItem(name: "fields", value: "id,title,artist_display,date_display,date_start,date_end,image_id,medium_display,dimensions,credit_line,department_title,artwork_type_title"))
            
        case .searchArtworks(let query, let page, let limit):
            items.append(URLQueryItem(name: "q", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            items.append(URLQueryItem(name: "fields", value: "id,title,artist_display,date_display,date_start,date_end,image_id,medium_display,dimensions,credit_line,department_title,artwork_type_title"))
            
        case .artworkDetail:
            items.append(URLQueryItem(name: "fields", value: "id,title,artist_display,date_display,date_start,date_end,image_id,medium_display,dimensions,credit_line,department_title,artwork_type_title,description,place_of_origin"))
            
        case .searchByArtist(let artistName, let limit):
            items.append(URLQueryItem(name: "q", value: artistName))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            items.append(URLQueryItem(name: "fields", value: "id,title,artist_display,date_display,image_id"))
        }
        
        return items
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
