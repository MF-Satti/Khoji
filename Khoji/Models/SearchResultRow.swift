import Foundation
import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack {
            Image(nsImage: result.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(result.name)
                    .font(.headline)
                Text(result.path)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Modified: \(result.date, formatter: dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
