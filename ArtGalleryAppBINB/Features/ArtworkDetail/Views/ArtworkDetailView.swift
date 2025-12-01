import SwiftUI


struct JustifiedText: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.textAlignment = .justified
        textView.font = .systemFont(ofSize: 18)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
}
struct ArtworkDetailView: View {
    let artworkId: Int
    @StateObject private var viewModel = ArtworkDetailViewModel()
    @State private var mainImage: UIImage?
    @State private var isLoadingImage = false
    @State private var imageLoadFailed = false
    @State private var showFullScreen = false
    @State private var showDownloadAlert = false
    @State private var downloadSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Main image with fullscreen option (Story 6)
                ZStack {
                    if let image = mainImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .onTapGesture {
                                showFullScreen = true
                            }
                    } else if isLoadingImage {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1.5, contentMode: .fit)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .overlay(
                                VStack {
                                    ProgressView()
                                    Text("Loading image...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                            )
                    } else if imageLoadFailed {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1.5, contentMode: .fit)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Failed to load image")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Button("Retry") {
                                        Task {
                                            await loadMainImage()
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            )
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1.5, contentMode: .fit)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                
                // Artwork details (Story 4)
                if let artwork = viewModel.artwork {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(artwork.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let artist = artwork.artistDisplay {
                            Text(artist)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let date = artwork.dateDisplay {
                            Label(date, systemImage: "calendar")
                                .font(.subheadline)
                        }
                        
                        if let medium = artwork.mediumDisplay {
                            Label(medium, systemImage: "paintpalette")
                                .font(.subheadline)
                        }
                        
                        if let dimensions = artwork.dimensions {
                            Label(dimensions, systemImage: "ruler")
                                .font(.subheadline)
                        }
                        
                        if let description = artwork.description {
                            Text("About")
                                .font(.headline)
                                .padding(.top)
                            
       
                            Text(
                                JustifiedText(text: description)
                                .htmlToPlainText()
                                .font(.body)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                        }
                    }
                    .padding()
                }
                
                // Story 5: Related artworks
                if !viewModel.relatedArtworks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("More from this Artist")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.relatedArtworks) { artwork in
                                    NavigationLink(destination: ArtworkDetailView(artworkId: artwork.id)) {
                                        RelatedArtworkCard(artwork: artwork)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Story 6: Download button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        downloadSuccess = await viewModel.downloadImage()
                        showDownloadAlert = true
                    }
                } label: {
                    Image(systemName: "arrow.down.circle")
                }
                .disabled(mainImage == nil)
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            // Story 6: Fullscreen view
            FullScreenImageView(image: mainImage)
        }
        .alert(downloadSuccess ? "Saved to Photos" : "Failed to Save", isPresented: $showDownloadAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if !downloadSuccess, let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.loadArtwork(id: artworkId)
            await loadMainImage()
        }
    }
    
    private func loadMainImage() async {
        guard let imageId = viewModel.artwork?.imageId else {
            imageLoadFailed = true
            return
        }
        
        isLoadingImage = true
        imageLoadFailed = false
        mainImage = nil
        
        print("🖼️ Loading detail image for: \(imageId)")
        
        do {
            // Try medium size first (faster)
            mainImage = try await ImageService.shared.loadImage(imageId: imageId, size: .medium)
            print("✅ Image loaded successfully")
        } catch {
            print("❌ Failed to load image: \(error)")
            imageLoadFailed = true
        }
        
        isLoadingImage = false
    }
}
