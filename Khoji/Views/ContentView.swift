import SwiftUI

struct ContentView: View {
    @ObservedObject var searchSharedState: SearchViewModel
    
    @State private var showSettings = false
    @State private var searchSettings = SearchSettings()
    
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
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIConstants.iconSize, height: UIConstants.iconSize)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, UIConstants.searchBarPadding)
                .popover(isPresented: $showSettings) {
                    SearchSettingsView(settings: $searchSettings)
                        .onDisappear {
                            searchSharedState.searchSettings = searchSettings
                        }
                }
            }
            .background(Color(.systemGray))
            .cornerRadius(UIConstants.searchBarCornerRadius)
            
            if !searchSharedState.searchText.isEmpty {
                List {
                    // existing search results
                    ForEach(searchSharedState.searchResults) { result in
                        Button(action: {
                            FileManagerService.shared.openFile(atPath: result.path)
                        }) {
                            SearchResultRow(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // "Search the web" entry
                    Button(action: {
                        // Implement your web search action here
                        print("Search the web for: \(searchSharedState.searchText)")
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                            Text("Search the web for: \(searchSharedState.searchText)")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }.onAppear {
            FileManagerService.shared.reestablishAccessToFolder()
        }
    }
}

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
