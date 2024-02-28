import SwiftUI
import AppKit

@main
struct KhojiApp: App {
    // Use AppKit's App Lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Remove the WindowGroup and its ContentView to prevent SwiftUI from creating a default window.
    var body: some Scene {
        // No window content here, managed through AppDelegate instead
        EmptyScene()
    }
}

struct EmptyScene: Scene {
    var body: some Scene {
        // This scene does nothing and should not create a new window.
        Settings { EmptyView() }
    }
}
