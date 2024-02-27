import Foundation

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
