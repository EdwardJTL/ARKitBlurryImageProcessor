//
//  ContentView.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    let arvc = ARSCNViewController()
    @State var presentGallery: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ARView(arvc)
                .edgesIgnoringSafeArea(.all)
            Button(action: {
                withAnimation {
                    presentGallery.toggle()
                }
            }, label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.largeTitle)
                    .padding()
                    .background(Circle().fill(Color.white))
            })
        }
        .sheet(isPresented: $presentGallery) {
            galleryView
                .padding([.bottom, .horizontal])
        }
    }

    var galleryView: some View {
        VStack {
            Spacer()
            Button("Capture") {

            }
            .buttonStyle(HugeButtonStyle(bgColor: .accentColor))
            Button("Close") {
                presentGallery.toggle()
            }
            .buttonStyle(HugeButtonStyle(bgColor: .red))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
