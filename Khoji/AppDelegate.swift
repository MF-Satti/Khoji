import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!
    var sharedState = SearchViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        windowManager = WindowManager(sharedState: sharedState)
        FileManagerService.shared.delegate = windowManager
    }
}
