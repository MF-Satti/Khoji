import Foundation
import AppKit

struct SearchResult: Identifiable {
    let id: UUID = UUID()
    let name: String
    let path: String
    let icon: NSImage
    let date: Date
}
