import SwiftUI

struct ContentView: View {
    @ObservedObject var sharedState: SearchViewModel

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
                List(sharedState.searchResults) { result in
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
            self.reestablishAccessToDownloadsFolder()
        }
    }
    /**
     To integrate the folder access request flow into the SwiftUI ContentView, will need to adapt some parts to work within SwiftUI's lifecycle and state management system. Since SwiftUI doesn't directly support calling NSOpenPanel from within its views (as it's a UI component from AppKit), will typically use a Coordinator or similar mechanism to bridge AppKit functionality with SwiftUI. However, for simplicity and to stick closely to the existing code structure, will focus on a straightforward approach that triggers the access request flow from the openFile(atPath:) function, depending on whether user has previously stored access permissions.
     */
    private func openFile(atPath path: String) {
        // Check if we have stored access for the folder containing the file
        if hasStoredAccessForFolderContainingFile(atPath: path) {
            // Use the stored access to open the file directly
            let url = URL(fileURLWithPath: path).standardizedFileURL
            NSWorkspace.shared.open(url)
        } else {
            // Dynamically determine the directory from the path
            if let directory = directory(forPath: path) {
                // If no stored access, request folder access first for the determined directory
                requestAccessToFolder(directory) {
                    // Retry opening the file after obtaining access
                    self.openFile(atPath: path)
                }
            } else {
                // Handle case where the directory is not one of the specified types or access cannot be determined
                print("Cannot determine folder access for path: \(path)")
            }
        }
    }
    
    func directory(forPath path: String) -> AccessibleDirectory? {
        /*let standardizedPath = URL(fileURLWithPath: path).standardized.path
        guard let downloadsPath = AccessibleDirectory.downloads.url?.path,
              let documentsPath = AccessibleDirectory.documents.url?.path,
              let desktopPath = AccessibleDirectory.desktop.url?.path else {
            return nil
        }
         if standardizedPath.hasPrefix("Downloads") {
             return .downloads
         } else if standardizedPath.hasPrefix("Documents") {
             return .documents
         } else if standardizedPath.hasPrefix("Desktop") {
             return .desktop
         }
         
         */
        
        // May only work for sandboxed environment
        if path.contains("Downloads") {
            return .downloads
        } else if path.contains("Documents") {
            return .documents
        } else if path.contains("Desktop") {
            return .desktop
        }
        
        return nil
    }
    
    func requestAccessToFolder(_ directory: AccessibleDirectory, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            guard let directoryURL = directory.url else {
                print("Directory URL not found.")
                return
            }

            let openPanel = NSOpenPanel()
            openPanel.message = "Please select the \(directory) folder to grant access"
            openPanel.prompt = "Grant Access"
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = false
            openPanel.allowsMultipleSelection = false
            openPanel.directoryURL = directoryURL
            
            openPanel.begin { response in
                if response == .OK, let url = openPanel.url {
                    // Save access permissions if needed, for example using security-scoped bookmarks
                    self.persistAccessToFolder(url: url)
                    completion()
                } else {
                    // Handle the case where the user did not grant access
                    // Possibly show an error or alert to the user
                }
            }
        }
    }
    
    func hasStoredAccessForFolderContainingFile(atPath path: String) -> Bool {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderAccessBookmark") else {
            return false
        }
        
        var isStale = false
        do {
            let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                // The bookmark data is stale and needs to be saved again. This can happen if the file or folder was moved.
                // For simplicity, we're not handling this case here. In a real app, you might want to save the new bookmark data.
                print("Bookmark data is stale")
                return false
            }
            
            // Start accessing the security-scoped resource.
            guard bookmarkedURL.startAccessingSecurityScopedResource() else {
                // Unable to access the resource.
                return false
            }
            
            // Compare the directory of the file path with the bookmarked URL
            let fileURL = URL(fileURLWithPath: path)
            let fileDirectoryURL = fileURL.deletingLastPathComponent()
            let hasAccess = bookmarkedURL == fileDirectoryURL
            
            // Make sure to stop accessing the security-scoped resource when you’re done.
            bookmarkedURL.stopAccessingSecurityScopedResource()
            
            return hasAccess
        } catch {
            print("Error resolving bookmark data: \(error)")
            return false
        }
    }

    
    func persistAccessToFolder(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Storing bookmark data in UserDefaults. Might use KeyChain later.
            UserDefaults.standard.set(bookmarkData, forKey: "folderAccessBookmark")
        } catch {
            print("Error saving bookmark data: \(error)")
        }
    }
    
    func reestablishAccessToDownloadsFolder() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderAccessBookmark") else {
            return
        }

        var isStale = false
        do {
            let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // Handle stale bookmark data, maybe by requesting access again
                print("Bookmark data is stale. Need to request access again.")
                return
            }

            if bookmarkedURL.startAccessingSecurityScopedResource() {
                // Successfully re-established access.
                // You can stop accessing when you no longer need access, or you might keep it for the app's lifetime, depending on your use case.
                // Consider where to call `stopAccessingSecurityScopedResource()` if you start it here.
            } else {
                print("Failed to re-establish access using bookmark.")
            }
        } catch {
            print("Error resolving bookmark data: \(error)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Directory type enum
enum AccessibleDirectory {
    case downloads
    case documents
    case desktop

    var url: URL? {
        switch self {
        case .downloads:
            return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        case .desktop:
            return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        }
    }
}
