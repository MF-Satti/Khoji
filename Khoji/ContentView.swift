import SwiftUI

struct ContentView: View {
    @ObservedObject var searchSharedState: SearchViewModel
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search here...", text: $searchSharedState.searchText)
                    .padding(UIConstants.searchBarPadding)
                    .frame(height: UIConstants.searchBarHeight)
                    .font(.system(size: UIConstants.searchBarFontSize))
                    .shadow(radius: 5)
                Button(action: {
                    // TODO: Add settings action here for advanced search criteria, search by type, size, date etc
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIConstants.iconSize, height: UIConstants.iconSize)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, UIConstants.searchBarPadding)
            }
            .background(Color(.systemGray))
            .cornerRadius(UIConstants.searchBarCornerRadius)
            
            if !searchSharedState.searchText.isEmpty {
                List(searchSharedState.searchResults) { result in
                    Button(action: {
                        openFile(atPath: result.path)
                    }) {
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
                    .buttonStyle(PlainButtonStyle()) // could use TapGesture afterwards
                }
                .frame(maxHeight: 200)
            }
        }.onAppear {
            FileManagerService.shared.reestablishAccessToDownloadsFolder()
        }
    }
    
    private func openFile(atPath path: String) {
        FileManagerService.shared.openFile(atPath: path)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
