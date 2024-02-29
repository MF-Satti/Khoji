import Foundation

@objc protocol WindowManagerDelegate: AnyObject {
    func hideSearchWindow()
    func showSearchWindow()
    @objc optional func showAlert(withMessage message: String, informativeText: String)
}
