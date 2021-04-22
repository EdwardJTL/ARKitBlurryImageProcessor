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

    @State var gridSize: CGFloat = 100.0
    var columns: [GridItem] { [GridItem(.adaptive(minimum: gridSize))] }

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
        VStack(alignment:.center) {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(galleryModel.images.indices, id: \.self) { idx in
                        GalleryItemView(image: galleryModel.images[idx],
                                        laplacian: galleryModel.laplacians[idx, default: Image(systemName: "photo")],
                                        score: galleryModel.scores[idx, default: -1.0])
                    }
                }
            }
            .padding()
            Spacer()
            Slider(value: $gridSize, in: 100...350, step: 10) {
                Text("Grid Size")
            }
            Button("Burst") {
                galleryModel.burstCapture()
            }
            .disabled(galleryModel.inBurstMode)
            .buttonStyle(HugeButtonStyle(bgColor: .purple))
            Button("Capture") {
                galleryModel.insert(arvc.session.currentFrame?.capturedImage)
            }
            .disabled(galleryModel.inBurstMode)
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
    let laplacian: Image
    let score: Float

    @State var showLaplacian = false

    var body: some View {
        VStack {
            Group {
                if showLaplacian {
                    laplacian
                        .resizable()
                        .scaledToFit()
                } else {
                    image
                        .resizable()
                        .scaledToFit()
                }
            }
            Text("Blurry score: \(score)")
                .font(.headline)
        }
        .onTapGesture {
            showLaplacian.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
