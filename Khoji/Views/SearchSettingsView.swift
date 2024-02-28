import Foundation
import SwiftUI

struct SearchSettingsView: View {
    @Binding var settings: SearchSettings
    @Environment(\.dismiss) var dismiss
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var minSize = 0.0
    @State private var maxSize = 100.0
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Search by Date", isOn: $settings.searchByDate)
                if settings.searchByDate {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Toggle("Search by Size", isOn: $settings.searchBySize)
                if settings.searchBySize {
                    HStack {
                        Text("Minimum Size: \(minSize, specifier: "%.1f") MB")
                        Slider(value: $minSize, in: 0...maxSize)
                    }
                    HStack {
                        Text("Maximum Size: \(maxSize, specifier: "%.1f") MB")
                        Slider(value: $maxSize, in: minSize...1000) // 1000 MB as a max value for now
                    }
                }
            }
            .navigationTitle("Search Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .padding()
        .frame(width: 250, height: 250) // TODO: fix dynamic resizing
    }
}
