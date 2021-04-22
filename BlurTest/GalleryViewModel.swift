//
//  GalleryViewModel.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import Combine
import Foundation
import SwiftUI
import VideoToolbox

class GalleryViewModel: ObservableObject {
    @Published var images: [Image] = []
    @Published var scores: [Int: Float] = [:]

    weak var detector: BlurDetector?
    let context = CIContext(options: nil)

    func insert(_ cvBuffer: CVPixelBuffer?) {
        guard let cvBuffer = cvBuffer,
              let detector = detector else { return }
        detector.calculateBlur(for: cvBuffer) { [weak self] score in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let ciImage = CIImage(cvPixelBuffer: cvBuffer)
                let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)
                guard let safeCGImage = cgImage else { return }
                self.images.append(Image(decorative: safeCGImage, scale: 1.0, orientation: .up))
                guard let idx = self.images.indices.last else { return }
                self.scores[idx] = score
            }
        }
    }
}
