//
//  ContentView.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var galleryModel: GalleryViewModel
    @Environment(\.blurDetector) var blurDetector: BlurDetector
    @Environment(\.arvc) var arvc: ARSCNViewController

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
            List {
                ForEach(galleryModel.images.indices, id: \.self) { idx in
                    GalleryItemView(image: galleryModel.images[idx],
                                    score: galleryModel.scores[idx, default: -1.0])
                }
            }
            Spacer()
            Button("Capture") {
                galleryModel.insert(arvc.session.currentFrame?.capturedImage)
            }
            .buttonStyle(HugeButtonStyle(bgColor: .accentColor))
            Button("Close") {
                presentGallery.toggle()
            }
            .buttonStyle(HugeButtonStyle(bgColor: .red))
        }
    }
}

private struct GalleryItemView: View {
    let image: Image
    let score: Float

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
            Text("Blurry score: \(score)")
                .font(.headline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
