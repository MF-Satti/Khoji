import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var sharedState: SharedState

    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search here...", text: $sharedState.searchText)
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
            
            if !sharedState.searchText.isEmpty {
                List(sharedState.searchResults, id: \.self) { item in
                    Text(item)
                }
                .frame(maxHeight: 200)
            }
        }
    }
}

// Also a Search ViewModel
class SharedState: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [String] = []

    private var query: NSMetadataQuery?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newText in
                self?.performSearch(query: newText)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            return
        }

        // Stop previous query if any
        query?.stop()
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: nil)

        // Initialize query
        let metadataQuery = NSMetadataQuery()
        metadataQuery.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", NSMetadataItemFSNameKey, searchText)
        metadataQuery.searchScopes = [NSMetadataQueryUserHomeScope, NSMetadataQueryLocalComputerScope]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidFinishGathering(_:)),
            name: .NSMetadataQueryDidFinishGathering,
            object: metadataQuery)

        self.query = metadataQuery
        metadataQuery.start()
    }

    @objc private func queryDidFinishGathering(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        query.stop() // Important to stop the query to free up resources

        var results: [String] = []
        for item in query.results as! [NSMetadataItem] {
            if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                results.append(path)
            }
        }

        DispatchQueue.main.async {
            self.searchResults = results
        }

        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
    }
}

/*#Preview {
    ContentView()
}*/
