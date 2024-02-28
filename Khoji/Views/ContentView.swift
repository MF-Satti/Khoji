import SwiftUI
import AppKit

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
                        searchTheWeb(for: searchSharedState.searchText)
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
    
    func searchTheWeb(for query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") else {
            print("failed to create search URL")
            return
        }
        
        NSWorkspace.shared.open(url)
    }
}
