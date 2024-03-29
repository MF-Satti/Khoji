import Foundation
import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var searchSettings = SearchSettings()
    @Published var isSearching: Bool = false
    
    @Published var showSettings = false

    private var query: NSMetadataQuery?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // observe searchText changes
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newText in
                self?.performSearch(query: newText)
            }
            .store(in: &cancellables)
        
        // observe searchSettings changes
        $searchSettings
            .sink { [weak self] newSettings in
                // only perform the search if searchText is not empty, to avoid unnecessary queries
                if !(self?.searchText.isEmpty ?? true) {
                    self?.performSearch(query: self?.searchText ?? "")
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(query searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            return
        }
        self.isSearching = true
        query?.stop() // Stop previous query if any
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: nil)

        // Initialize query - system wide
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

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let rawResults = query.results as! [NSMetadataItem]
            var filteredResults: [SearchResult] = []

            for item in rawResults {
                guard let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                      let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String,
                      let date = item.value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date,
                      let fileSize = item.value(forAttribute: NSMetadataItemFSSizeKey) as? NSNumber else {
                    continue
                }
                
                // convert fileSize to Double (in MB for comparison)
                let fileSizeMB = fileSize.doubleValue / (1024 * 1024)
                
                // check if item matches the date and size criteria
                let matchesDateCriteria = !(self?.searchSettings.searchByDate ?? true) ||
                    ((self?.searchSettings.startDate ?? .distantPast) <= date && date <= (self?.searchSettings.endDate ?? .distantFuture))
                let matchesSizeCriteria = !(self?.searchSettings.searchBySize ?? true) ||
                    ((self?.searchSettings.minSize ?? 0.0) <= fileSizeMB && fileSizeMB <= (self?.searchSettings.maxSize ?? Double.greatestFiniteMagnitude))
                
                if matchesDateCriteria && matchesSizeCriteria {
                    let icon = NSWorkspace.shared.icon(forFile: path)
                    let result = SearchResult(name: name, path: path, icon: icon, date: date)
                    filteredResults.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self?.searchResults = filteredResults
                self?.isSearching = false
            }
        }
    }
}
