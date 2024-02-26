import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // set the app to be an accessory so it doesn't appear in the dock or force a new window to open.
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Create a subclass of NSWindow to ensure it can become key
        class KeyWindow: NSWindow {
            override var canBecomeKey: Bool {
                return true
            }
        }
        
        // create the floating search bar window
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
        
        let contentView = NSHostingView(rootView: ContentView())
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
        window.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
}
