import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var startYear = 1800
    @State private var endYear = 2024
    
    let onApply: (Int, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Year Range") {
                    Stepper("Start Year: \(startYear)", value: $startYear, in: 1000...2024)
                    Stepper("End Year: \(endYear)", value: $endYear, in: 1000...2024)
                }
                
                Section {
                    Button("Apply Filter") {
                        onApply(startYear, endYear)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Filter Artworks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
