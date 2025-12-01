import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var startYear = "1800"
    @State private var endYear = "2024"
    
    let onApply: (Int, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Year Range") {
                    HStack {
                        Text("Start Year:")
                        TextField("Start Year", text: $startYear)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("End Year:")
                        TextField("End Year", text: $endYear)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Button("Apply Filter") {
                        let start = Int(startYear) ?? 1800
                        let end = Int(endYear) ?? 2024
                        onApply(start, end)
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
