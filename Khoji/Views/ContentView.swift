import SwiftUI

struct ContentView: View {
    @ObservedObject var searchSharedState: SearchViewModel
    
    @State private var showSettings = false
    @State private var searchSettings = SearchSettings()
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search here...", text: $searchSharedState.searchText)
                    .padding(UIConstants.searchBarPadding)
                    .frame(height: UIConstants.searchBarHeight)
                    .font(.system(size: UIConstants.searchBarFontSize))
                    .shadow(radius: 5)
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIConstants.iconSize, height: UIConstants.iconSize)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, UIConstants.searchBarPadding)
                .popover(isPresented: $showSettings) {
                    SearchSettingsView(settings: $searchSettings)
                        .onDisappear {
                            searchSharedState.searchSettings = searchSettings
                        }
                }
            }
            .background(Color(.systemGray))
            .cornerRadius(UIConstants.searchBarCornerRadius)
            
            if !searchSharedState.searchText.isEmpty {
                List(searchSharedState.searchResults) { result in
                    Button(action: {
                        openFile(atPath: result.path)
                    }) {
                        HStack {
                            Image(nsImage: result.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text(result.name)
                                    .font(.headline)
                                Text(result.path)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Modified: \(result.date, formatter: dateFormatter)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // could use TapGesture afterwards
                }
                .frame(maxHeight: 200)
            }
        }.onAppear {
            FileManagerService.shared.reestablishAccessToFolder()
        }
    }
    
    private func openFile(atPath path: String) {
        FileManagerService.shared.openFile(atPath: path) // TODO: add opacity or a way to actually see the opened panel
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
