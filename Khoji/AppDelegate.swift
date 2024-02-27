import Foundation
import AppKit
import SwiftUI
import Combine
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var sharedState = SharedState()

    override init() {
        super.init()
        // observe changes to searchText
        sharedState.$searchText
            .sink { [weak self] newText in
                self?.adjustWindowSize(forText: newText)
            }
            .store(in: &cancellables)
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func adjustWindowSize(forText text: String) {
        guard window != nil else { return } // ensure the window exists

        let newHeight = text.isEmpty ? UIConstants.searchBarHeight : UIConstants.searchBarHeight + 200
        DispatchQueue.main.async { [weak self] in
            self?.window.setContentSize(NSSize(width: UIConstants.searchBarWidth, height: newHeight))
            self?.window.center()
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // set the app to be an accessory so it doesn't appear in the dock or force a new window to open.
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Create a subclass of NSWindow to ensure it can become key
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
        
        let contentView = NSHostingView(rootView: ContentView(sharedState: sharedState))
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
        window.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
}
