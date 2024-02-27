import Foundation
import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []

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
        query.stop() // stop query to free up resources
        
        var results: [SearchResult] = []
        for item in query.results as! [NSMetadataItem] {
            if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
               let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String,
               let date = item.value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date {
                let icon = NSWorkspace.shared.icon(forFile: path)
                let result = SearchResult(name: name, path: path, icon: icon, date: date)
                results.append(result)
            }
        }
        
        DispatchQueue.main.async {
            self.searchResults = results
        }
    }
}
