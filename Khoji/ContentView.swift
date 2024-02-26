import SwiftUI

struct ContentView: View {
    @State private var searchText = ""

    var body: some View {
        HStack {
            TextField("Search here...", text: $searchText)
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
    }
}


/*#Preview {
    ContentView()
}*/
