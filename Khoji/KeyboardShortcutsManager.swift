import Foundation
import AppKit

class KeyboardShortcutsManager {
    private weak var windowManager: WindowManager?
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    ///https://stackoverflow.com/questions/47181412/monitoring-nsevents-using-addglobalmonitorforevents-missing-gesture-events
    func registerGlobalShortcut() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            let commandKey = NSEvent.ModifierFlags.command.rawValue
            let commaKey = ","
            let flags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            
            if flags == commandKey && event.characters == commaKey {
                DispatchQueue.main.async {
                    self?.windowManager?.toggleSearchSettingsView()
                }
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            let commandKey = NSEvent.ModifierFlags.command.rawValue
            let commaKey = ","
            let flags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            
            if flags == commandKey && event.characters == commaKey {
                self?.windowManager?.toggleSearchSettingsView()
                return nil
            }
            return event
        }
    }
}
