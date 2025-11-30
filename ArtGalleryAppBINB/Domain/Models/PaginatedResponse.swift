import Foundation

struct PaginatedResponse<T> {
    let data: [T]
    let pagination: Pagination
}

struct Pagination {
    let total: Int
    let limit: Int
    let currentPage: Int
    let totalPages: Int

    var hasNextPage: Bool {
        return currentPage < totalPages
    }
}
