//
//  ContentView.swift
//  Khoji
//
//  Created by M. Faizan Satti on 26/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)
            .padding(UIConstants.searchBarPadding)
            .frame(height: UIConstants.searchBarHeight)
            .font(.system(size: UIConstants.searchBarFontSize))
            .shadow(radius: 5)
    }
}


/*#Preview {
    ContentView()
}*/
