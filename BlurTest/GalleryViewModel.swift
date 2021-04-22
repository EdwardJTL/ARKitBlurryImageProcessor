//
//  GalleryViewModel.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import ARKit
import Combine
import Foundation
import SwiftUI
import VideoToolbox

class GalleryViewModel: ObservableObject {
    @Published var images: [Image] = []
    @Published var scores: [Int: Float] = [:]
    @Published var laplacians: [Int: Image] = [:]

    @Published var inBurstMode = false
    @Published var maxBurst: Int = 3
    var burstCounter = 0


    weak var detector: BlurDetector?
    let context = CIContext(options: nil)

    func insert(_ cvBuffer: CVPixelBuffer?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let cvBuffer = cvBuffer,
                  let detector = self.detector else { return }
            let ciImage = CIImage(cvPixelBuffer: cvBuffer)
            let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)
            guard let safeCGImage = cgImage else { return }
            detector.calculateBlur(for: cvBuffer) { [weak self] score, laplacian in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.images.append(Image(decorative: safeCGImage, scale: 1.0, orientation: .up))
                    guard let idx = self.images.indices.last else { return }
                    self.scores[idx] = score
                    if let laplacian = laplacian,
                       let cgLaplacian = self.context.createCGImage(laplacian, from: laplacian.extent) {
                        self.laplacians[idx] = Image(decorative: cgLaplacian, scale: 1.0, orientation: .up)
                    }
                }
            }
        }
    }

    func burstCapture() {
        inBurstMode = true
        burstCounter = maxBurst
    }
}

extension GalleryViewModel: ARFrameReceiver {
    func send(frame: ARFrame) {
        guard inBurstMode else { return }
        insert(frame.capturedImage)
        burstCounter -= 1
        inBurstMode = burstCounter > 0
    }
}
