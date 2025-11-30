import Foundation

@MainActor
class ArtworkListViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filterStartYear: Int?
    @Published var filterEndYear: Int?

    private let repository: ArtworkRepositoryProtocol
    private var currentPage = 1
    private let pageLimit = 20
    private var canLoadMore = true
    private var isSearchActive = false
    private var isFilterActive = false

    init(repository: ArtworkRepositoryProtocol) {
        self.repository = repository
    }

    func loadArtworks() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                let response = try await repository.fetchArtworks(page: 1, limit: pageLimit)
                artworks = response.data
                currentPage = 1
                canLoadMore = response.pagination.hasNextPage
            } catch {
                errorMessage = handleError(error)
            }

            isLoading = false
        }
    }

    func loadMore() {
        guard !isLoading, canLoadMore else { return }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                let nextPage = currentPage + 1
                let response: PaginatedResponse<Artwork>

                if isSearchActive {
                    response = try await repository.searchArtworks(query: searchText, page: nextPage, limit: pageLimit)
                } else if isFilterActive {
                    response = try await repository.filterArtworksByYear(startYear: filterStartYear, endYear: filterEndYear, page: nextPage, limit: pageLimit)
                } else {
                    response = try await repository.fetchArtworks(page: nextPage, limit: pageLimit)
                }

                artworks.append(contentsOf: response.data)
                currentPage = nextPage
                canLoadMore = response.pagination.hasNextPage
            } catch {
                errorMessage = handleError(error)
            }

            isLoading = false
        }
    }

    func searchArtworks() {
        guard !searchText.isEmpty else {
            clearSearch()
            return
        }

        Task {
            isLoading = true
            errorMessage = nil
            isSearchActive = true
            isFilterActive = false

            do {
                let response = try await repository.searchArtworks(query: searchText, page: 1, limit: pageLimit)
                artworks = response.data
                currentPage = 1
                canLoadMore = response.pagination.hasNextPage
            } catch {
                errorMessage = handleError(error)
            }

            isLoading = false
        }
    }

    func clearSearch() {
        searchText = ""
        isSearchActive = false
        if !isFilterActive {
            loadArtworks()
        }
    }

    func applyYearFilter(startYear: Int?, endYear: Int?) {
        self.filterStartYear = startYear
        self.filterEndYear = endYear

        guard startYear != nil || endYear != nil else {
            clearFilter()
            return
        }

        Task {
            isLoading = true
            errorMessage = nil
            isFilterActive = true
            isSearchActive = false
            searchText = ""

            do {
                let response = try await repository.filterArtworksByYear(startYear: startYear, endYear: endYear, page: 1, limit: pageLimit)
                artworks = response.data
                currentPage = 1
                canLoadMore = response.pagination.hasNextPage
            } catch {
                errorMessage = handleError(error)
            }

            isLoading = false
        }
    }

    func clearFilter() {
        filterStartYear = nil
        filterEndYear = nil
        isFilterActive = false
        if !isSearchActive {
            loadArtworks()
        }
    }

    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription ?? "An error occurred"
        }
        return error.localizedDescription
    }
}
