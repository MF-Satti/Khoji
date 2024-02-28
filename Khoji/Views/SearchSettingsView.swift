import Foundation
import SwiftUI

struct SearchSettingsView: View {
    @Binding var settings: SearchSettings
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Search by Date", isOn: $settings.searchByDate)
                if settings.searchByDate {
                    DatePicker("Start Date", selection: Binding(
                        get: { self.settings.startDate ?? Date() },
                        set: { self.settings.startDate = $0 }
                    ), displayedComponents: .date)
                    DatePicker("End Date", selection: Binding(
                        get: { self.settings.endDate ?? Date() },
                        set: { self.settings.endDate = $0 }
                    ), displayedComponents: .date)
                }
                
                Toggle("Search by Size", isOn: $settings.searchBySize)
                if settings.searchBySize {
                    HStack {
                        Text("Minimum Size: \(settings.minSize ?? 0.0, specifier: "%.1f") MB")
                        Slider(value: Binding(
                            get: { self.settings.minSize ?? 0.0 },
                            set: { self.settings.minSize = $0 }
                        ), in: 0...((settings.maxSize ?? 100.0) as Double))
                    }
                    HStack {
                        Text("Maximum Size: \(settings.maxSize ?? 100.0, specifier: "%.1f") MB")
                        Slider(value: Binding(
                            get: { self.settings.maxSize ?? 100.0 },
                            set: { self.settings.maxSize = $0 }
                        ), in: (settings.minSize ?? 0.0)...100.0)
                    }
                }
            }
            .frame(width: 330, height: 330)
            .navigationTitle("Search Settings")
        }
        .padding()
        .frame(width: 360, height: 360)
        //.adjustsWindowSizeDynamically() // TODO: fix dynamic resizing
    }
}

// SwiftUI - AppKit bridging for UI dynamic content resizing // TODO: broke after introducing content to `SearchSettingsView`
struct CustomSizedSheetView: NSViewControllerRepresentable {
    typealias NSViewControllerType = NSHostingController<SearchSettingsView>
    
    @Binding var settings: SearchSettings
    
    func makeNSViewController(context: Context) -> NSHostingController<SearchSettingsView> {
        let viewController = NSHostingController(rootView: SearchSettingsView(settings: $settings))
        return viewController
    }
    
    func updateNSViewController(_ nsViewController: NSHostingController<SearchSettingsView>, context: Context) {
        nsViewController.rootView = SearchSettingsView(settings: $settings)
        
        // adjust the size of the window based on the content here
        // example for now, calculate the desired size dynamically
        if let window = nsViewController.view.window {
            let newSize = CGSize(width: 300, height: 300)
            window.setContentSize(newSize)
        }
    }
}

struct DynamicWindowSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowSizeAdjustingViewRepresentable())
    }
}

private struct WindowSizeAdjustingViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                let hostingController = NSHostingController(rootView: context.coordinator.content)
                window.contentViewController?.addChild(hostingController)
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                window.contentViewController?.view.addSubview(hostingController.view)
                
                NSLayoutConstraint.activate([
                    hostingController.view.topAnchor.constraint(equalTo: window.contentViewController!.view.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: window.contentViewController!.view.bottomAnchor),
                    hostingController.view.leadingAnchor.constraint(equalTo: window.contentViewController!.view.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: window.contentViewController!.view.trailingAnchor),
                ])
                
                context.coordinator.parent = hostingController
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        weak var parent: NSHostingController<AnyView>? {
            didSet {
                adjustWindowSize()
            }
        }
        
        var content: AnyView {
            AnyView(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        self.adjustWindowSize(newSize: geometry.size)
                    }
                }
            )
        }
        
        private func adjustWindowSize(newSize: CGSize? = nil) {
            guard let window = parent?.view.window else { return }
            var size = newSize ?? parent?.view.fittingSize ?? window.frame.size
            size.height += window.titlebarHeight // adjust for the title bar height
            window.setContentSize(size)
            window.center()
        }
    }
}

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}

extension View {
    func adjustsWindowSizeDynamically() -> some View {
        self.modifier(DynamicWindowSizeModifier())
    }
}
