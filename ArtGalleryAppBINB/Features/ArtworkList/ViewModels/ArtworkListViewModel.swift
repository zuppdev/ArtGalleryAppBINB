import Foundation

@MainActor
class ArtworkListViewModel: ObservableObject {
    @Published var artworks: [ArtworkSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    
    private let apiService = ArtworkAPIService.shared
    
    // Story 1: Load artworks
    func loadArtworks() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchArtworks(page: currentPage)
            artworks.append(contentsOf: response.data)
            hasMorePages = currentPage < response.pagination.totalPages
            currentPage += 1
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    // Story 2: Search
    func searchArtworks(query: String) async {
        isLoading = true
        errorMessage = nil
        artworks = []
        currentPage = 1
        
        do {
            let response = try await apiService.searchArtworks(query: query)
            artworks = response.data
            hasMorePages = false
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    // Story 3: Filter by year
    func filterByYear(startYear: Int, endYear: Int) async {
        isLoading = true
        errorMessage = nil
        artworks = []
        
        do {
            let response = try await apiService.filterArtworksByYear(startYear: startYear, endYear: endYear)
            artworks = response.data
            hasMorePages = false
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func reset() {
        artworks = []
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
    }
    
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Unknown error"
        }
        return error.localizedDescription
    }
}
