//
//  ArtworkListViewModel.swift
//  ArtGallery
//
//  ViewModel for artwork list screen
//

import Foundation

@MainActor
final class ArtworkListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var selectedYearRange: ClosedRange<Int>?
    @Published var isFilterActive = false
    
    // MARK: - Private Properties
    private let repository: ArtworkRepositoryProtocol
    private var currentPage = 1
    private let pageSize = 30
    private var searchTask: Task<Void, Never>?
    private var allArtworks: [Artwork] = [] // Store all artworks for filtering
    
    // MARK: - Initialization
    init(repository: ArtworkRepositoryProtocol = ArtworkRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func loadArtworks() {
        guard !isLoading, hasMorePages, searchQuery.isEmpty else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await repository.fetchArtworks(page: currentPage, limit: pageSize)
                
                if currentPage == 1 {
                    artworks = response.data
                    allArtworks = response.data
                } else {
                    artworks.append(contentsOf: response.data)
                    allArtworks.append(contentsOf: response.data)
                }
                
                currentPage += 1
                hasMorePages = response.pagination.currentPage < response.pagination.totalPages
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    func searchArtworks(_ query: String) {
        searchQuery = query
        
        // Cancel previous search task
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            // Reset to normal list
            isSearching = false
            resetPagination()
            loadArtworks()
            return
        }
        
        // Debounce search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            guard !Task.isCancelled else { return }
            
            isSearching = true
            isLoading = true
            errorMessage = nil
            currentPage = 1
            
            do {
                let response = try await repository.searchArtworks(query: query, page: 1, limit: pageSize)
                
                guard !Task.isCancelled else { return }
                
                artworks = response.data
                hasMorePages = response.pagination.currentPage < response.pagination.totalPages
                
                if artworks.isEmpty {
                    errorMessage = "No artworks found matching '\(query)'"
                }
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    func filterByYearRange(_ range: ClosedRange<Int>) {
        selectedYearRange = range
        isFilterActive = true
        
        // Filter artworks
        if searchQuery.isEmpty {
            artworks = allArtworks.filter { artwork in
                if let dateStart = artwork.dateStart {
                    return range.contains(dateStart)
                }
                return false
            }
        }
        
        if artworks.isEmpty {
            errorMessage = "No artworks found in years \(range.lowerBound)-\(range.upperBound)"
        }
    }
    
    func clearFilter() {
        selectedYearRange = nil
        isFilterActive = false
        artworks = allArtworks
        errorMessage = nil
    }
    
    func refresh() {
        resetPagination()
        searchQuery = ""
        isSearching = false
        selectedYearRange = nil
        isFilterActive = false
        loadArtworks()
    }
    
    func loadMoreIfNeeded(currentItem: Artwork) {
        guard let index = artworks.firstIndex(where: { $0.id == currentItem.id }) else {
            return
        }
        
        let thresholdIndex = artworks.count - 5
        if index >= thresholdIndex && !isLoading && hasMorePages {
            if isSearching {
                loadMoreSearchResults()
            } else {
                loadArtworks()
            }
        }
    }
    
    // MARK: - Private Methods
    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        artworks = []
        allArtworks = []
        errorMessage = nil
    }
    
    private func loadMoreSearchResults() {
        guard !isLoading, hasMorePages, !searchQuery.isEmpty else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await repository.searchArtworks(
                    query: searchQuery,
                    page: currentPage + 1,
                    limit: pageSize
                )
                
                artworks.append(contentsOf: response.data)
                currentPage += 1
                hasMorePages = response.pagination.currentPage < response.pagination.totalPages
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
