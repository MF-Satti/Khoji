import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!
    var keyboardShortcutsManager: KeyboardShortcutsManager!
    var sharedState = SearchViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        windowManager = WindowManager(sharedState: sharedState)
        keyboardShortcutsManager = KeyboardShortcutsManager(windowManager: windowManager)
        
        FileManagerService.shared.delegate = windowManager
        
        keyboardShortcutsManager.registerGlobalShortcut()
    }
}
