import SwiftUI

struct ArtworkListView: View {
    @StateObject private var viewModel = ArtworkListViewModel()
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Story 2: Search bar
                SearchBar(text: $searchText, onSearch: {
                    Task {
                        viewModel.reset()
                        await viewModel.searchArtworks(query: searchText)
                    }
                })
                
                // Error handling (Story 8: Negative cases)
                if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            viewModel.reset()
                            await viewModel.loadArtworks()
                        }
                    }
                } else if viewModel.artworks.isEmpty && !viewModel.isLoading {
                    EmptyStateView()
                } else {
                    // Story 1: Artwork list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.artworks) { artwork in
                                NavigationLink(destination: ArtworkDetailView(artworkId: artwork.id)) {
                                    ArtworkRowView(artwork: artwork)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 104)
                            }
                            
                            // Pagination
                            if viewModel.hasMorePages && !viewModel.artworks.isEmpty {
                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        Task {
                                            await viewModel.loadArtworks()
                                        }
                                    }
                            }
                        }
                    }
                }
                
                if viewModel.isLoading && viewModel.artworks.isEmpty {
                    LoadingView()
                }
            }
            .navigationTitle("Artworks")
            .toolbar {
                // Story 3: Filter button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView { startYear, endYear in
                    Task {
                        viewModel.reset()
                        await viewModel.filterByYear(startYear: startYear, endYear: endYear)
                    }
                }
            }
            .task {
                if viewModel.artworks.isEmpty {
                    await viewModel.loadArtworks()
                }
            }
        }
    }
}
