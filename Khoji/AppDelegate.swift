import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!
    var sharedState = SearchViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        windowManager = WindowManager(sharedState: sharedState)
        FileManagerService.shared.delegate = windowManager

        registerGlobalShortcut()
    }

    private func registerGlobalShortcut() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            let commandKey = NSEvent.ModifierFlags.command.rawValue
            let commaKey = ","
            let flags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            
            if flags == commandKey && event.characters == commaKey {
                DispatchQueue.main.async {
                    self?.windowManager.toggleSearchSettingsView()
                }
            }
        }

        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            let commandKey = NSEvent.ModifierFlags.command.rawValue
            let commaKey = ","
            let flags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            
            if flags == commandKey && event.characters == commaKey {
                self?.windowManager.toggleSearchSettingsView()
                return nil
            }
            return event
        }
    }
}
