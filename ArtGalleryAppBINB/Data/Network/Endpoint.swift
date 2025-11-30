import Foundation

enum Endpoint {
    case artworks(page: Int, limit: Int)
    case search(query: String, page: Int, limit: Int)
    case filterByYear(startYear: Int?, endYear: Int?, page: Int, limit: Int)
    case artworkDetail(id: Int)
    case artworksByArtist(artistId: Int, limit: Int)

    var baseURL: String {
        return "https://api.artic.edu/api/v1"
    }

    var path: String {
        switch self {
        case .artworks, .filterByYear:
            return "/artworks"
        case .search:
            return "/artworks/search"
        case .artworkDetail(let id):
            return "/artworks/\(id)"
        case .artworksByArtist:
            return "/artworks/search"
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }

    private var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        let fields = "id,title,artist_display,date_display,date_start,date_end,place_of_origin,dimensions,medium_display,credit_line,image_id,artist_id,artist_title,artwork_type_title,department_title,category_titles"
        items.append(URLQueryItem(name: "fields", value: fields))

        switch self {
        case .artworks(let page, let limit):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

        case .search(let query, let page, let limit):
            items.append(URLQueryItem(name: "q", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            items.append(URLQueryItem(name: "fields", value: fields))

        case .filterByYear(let startYear, let endYear, let page, let limit):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))

            var query: [String: Any] = [:]
            var rangeConditions: [[String: Any]] = []

            if let start = startYear {
                rangeConditions.append(["range": ["date_start": ["gte": start]]])
            }
            if let end = endYear {
                rangeConditions.append(["range": ["date_end": ["lte": end]]])
            }

            if !rangeConditions.isEmpty {
                query["bool"] = ["must": rangeConditions]

                if let jsonData = try? JSONSerialization.data(withJSONObject: query),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    items.append(URLQueryItem(name: "query", value: jsonString))
                }
            }

        case .artworkDetail:
            break

        case .artworksByArtist(let artistId, let limit):
            let query: [String: Any] = [
                "term": ["artist_id": artistId]
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: query),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                items.append(URLQueryItem(name: "query", value: jsonString))
            }
            items.append(URLQueryItem(name: "limit", value: "\(limit)"))
            items.append(URLQueryItem(name: "fields", value: fields))
        }

        return items
    }
}
