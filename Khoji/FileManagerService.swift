import Foundation
import Cocoa

/*class FileManagerService {
    static let shared = FileManagerService()
    weak var delegate: WindowManagerDelegate?
    
    func openFile(atPath path: String) {
        self.delegate?.hideSearchWindow()
        // check if have stored access for the folder containing the file
        if hasStoredAccessForFolderContainingFile(atPath: path) {
            // use the stored access to open the file directly
            let url = URL(fileURLWithPath: path).standardizedFileURL
            NSWorkspace.shared.open(url)
            self.delegate?.showSearchWindow()
        } else {
            // dynamically determine the directory from the path
            if let directory = directory(forPath: path) {
                // if no stored access, request folder access first for the determined directory
                requestAccessToFolder(directory) {
                    // retry opening the file after obtaining access
                    self.openFile(atPath: path)
                }
            } else {
                // handle case where the directory is not one of the specified types or access cannot be determined
                print("Cannot determine folder access for path: \(path)")
            }
        }
    }
    
    private func directory(forPath path: String) -> AccessibleDirectory? {
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
    
    private func requestAccessToFolder(_ directory: AccessibleDirectory, completion: @escaping () -> Void) {
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
                    // save access permissions if needed, for example using security-scoped bookmarks
                    self.persistAccessToFolder(url: url)
                    completion()
                } else {
                    self.delegate?.showSearchWindow()
                    self.delegate?.showAlert(withMessage: "Access Denied",
                                             informativeText: "You did not grant access to the folder. Please grant access to use this feature.")
                }
            }
        }
    }
    
    private func hasStoredAccessForFolderContainingFile(atPath path: String) -> Bool {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderAccessBookmark") else {
            return false
        }
        
        var isStale = false
        do {
            let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                // the bookmark data is stale and needs to be saved again. This can happen if the file or folder was moved.
                // for simplicity, not handling this case here, might want to save the new bookmark data.
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
    
    
    private func persistAccessToFolder(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            // storing bookmark data in UserDefaults. Might use KeyChain later.
            UserDefaults.standard.set(bookmarkData, forKey: "folderAccessBookmark")
        } catch {
            print("Error saving bookmark data: \(error)")
        }
    }
    
    func reestablishAccessToFolder() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "folderAccessBookmark") else {
            return
        }
        
        var isStale = false
        do {
            let bookmarkedURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // handle stale bookmark data, maybe by requesting access again
                print("Bookmark data is stale. Need to request access again.")
                return
            }
            
            if bookmarkedURL.startAccessingSecurityScopedResource() {
                // successfully re-established access
                // can stop accessing when no longer need access, or might keep it for the app's lifetime, depending on the use case.
                // consider where to call `stopAccessingSecurityScopedResource()` if we start it here.
            } else {
                print("Failed to re-establish access using bookmark.")
            }
        } catch {
            print("Error resolving bookmark data: \(error)")
        }
    }
}
*/
