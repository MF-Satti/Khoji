import Foundation
import Cocoa
import Combine
import SwiftUI

class WindowManager {
    var window: NSWindow!
    var sharedState: SearchViewModel
    var cancellables = Set<AnyCancellable>()
    
    init(sharedState: SearchViewModel) {
        self.sharedState = sharedState
        
        // observe changes to searchText
        self.sharedState.$searchText
            .sink { [weak self] newText in
                self?.adjustWindowSize(forText: newText)
            }
            .store(in: &cancellables)
        
        setupWindow()
    }
    
    func adjustWindowSize(forText text: String) {
        let newHeight = text.isEmpty ? UIConstants.searchBarHeight : UIConstants.searchBarHeight + 200
        DispatchQueue.main.async { [weak self] in
            self?.window.setContentSize(NSSize(width: UIConstants.searchBarWidth, height: newHeight))
            self?.window.center()
        }
    }
    
    private func setupWindow() {
        // create a subclass of NSWindow to ensure it can become key
        class KeyWindow: NSWindow {
            override var canBecomeKey: Bool {
                return true
            }
        }
        
        // create custom floating search bar window
        window = KeyWindow(
            contentRect: NSRect(x: 0, y: 0, width: UIConstants.searchBarWidth, height: UIConstants.searchBarHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        window.center()
        window.level = .floating
        window.collectionBehavior = .canJoinAllSpaces
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.hasShadow = true
        
        let contentView = NSHostingView(rootView: ContentView(searchSharedState: sharedState))
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
        window.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
}

protocol WindowManagerDelegate: AnyObject {
    func hideSearchWindow()
    func showSearchWindow()
}

extension WindowManager: WindowManagerDelegate {
    func hideSearchWindow() {
        DispatchQueue.main.async {
            self.window.orderOut(nil)
        }
    }

    func showSearchWindow() {
        DispatchQueue.main.async {
            self.window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
