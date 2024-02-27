import SwiftUI
import Combine

struct ContentView: View {
    @State private var searchText = ""
    @ObservedObject var sharedState: SharedState
    
    private let dummyResults = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search here...", text: $sharedState.searchText)
                    .padding(UIConstants.searchBarPadding)
                    .frame(height: UIConstants.searchBarHeight)
                    .font(.system(size: UIConstants.searchBarFontSize))
                    .shadow(radius: 5)
                Button(action: {
                    // TODO: Add settings action here for advanced search criteria, search by type, size, date etc
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIConstants.iconSize, height: UIConstants.iconSize)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, UIConstants.searchBarPadding)
            }
            .background(Color(.systemGray))
            .cornerRadius(UIConstants.searchBarCornerRadius)
            
            // List appears when user starts typing
            if !sharedState.searchText.isEmpty {
                List(dummyResults, id: \.self) { item in
                    Text(item)
                }
                .frame(maxHeight: 200)
            }
        }
    }
}

class SharedState: ObservableObject {
    @Published var searchText: String = ""
}

/*#Preview {
    ContentView()
}*/
