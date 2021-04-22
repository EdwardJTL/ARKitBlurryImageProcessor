//
//  ContentView.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARView()
        }
        .edgesIgnoringSafeArea(.all)
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
