import Foundation

class ArtworkAPIService {
    static let shared = ArtworkAPIService()
    private let baseURL = APIConstants.baseURL
    
    private init() {}
    
    // Story 1: Fetch artworks list
    func fetchArtworks(page: Int = 1, limit: Int = 20) async throws -> ArtworkListResponse {
        let urlString = "\(baseURL)/artworks?page=\(page)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id"
        return try await performRequest(urlString: urlString)
    }
    
    // Story 2: Search artworks
    func searchArtworks(query: String, limit: Int = 20) async throws -> ArtworkListResponse {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/artworks/search?q=\(encodedQuery)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id"
        return try await performRequest(urlString: urlString)
    }
    
    // Story 3: Filter by year
    func filterArtworksByYear(startYear: Int, endYear: Int, limit: Int = 100) async throws -> ArtworkListResponse {
        let urlString = "\(baseURL)/artworks/search?query[bool][must][][range][date_start][gte]=\(startYear)&query[bool][must][][range][date_start][lte]=\(endYear)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id"
        return try await performRequest(urlString: urlString)
    }
    
    // Story 4: Fetch artwork detail
    func fetchArtworkDetail(id: Int) async throws -> ArtworkDetail {
        let urlString = "\(baseURL)/artworks/\(id)?fields=id,title,artist_display,date_display,image_id,artist_id,description,dimensions,medium_display,is_public_domain,alt_image_ids"
        
        struct Response: Codable {
            let data: ArtworkDetail
        }
        
        let response: Response = try await performRequest(urlString: urlString)
        return response.data
    }
    
    // Story 5: Fetch artworks by artist
    func fetchArtworksByArtist(artistId: Int, limit: Int = 20) async throws -> ArtworkListResponse {
        let urlString = "\(baseURL)/artworks/search?query[term][artist_id]=\(artistId)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id"
        return try await performRequest(urlString: urlString)
    }
    
    // Generic request handler
    private func performRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error)
        }
    }
}
