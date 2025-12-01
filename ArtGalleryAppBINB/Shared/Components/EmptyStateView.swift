import SwiftUI

struct EmptyStateView: View {
    var title: String = "No Results"
    var message: String = "Try adjusting your search or filters"
    var icon: String = "photo.on.rectangle.angled"
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
