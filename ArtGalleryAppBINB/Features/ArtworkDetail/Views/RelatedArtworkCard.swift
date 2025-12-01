import SwiftUI

struct RelatedArtworkCard: View {
    let artwork: ArtworkSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(imageId: artwork.imageId, size: .thumbnail)
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(8)
            
            Text(artwork.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
                .foregroundColor(.primary)
            
            if let date = artwork.dateDisplay {
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 150, alignment: .leading)
            }
        }
    }
}
