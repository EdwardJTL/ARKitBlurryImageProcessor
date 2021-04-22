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
    @Published var laplacians: [Int: Image] = [:]

    weak var detector: BlurDetector?
    let context = CIContext(options: nil)

    func insert(_ cvBuffer: CVPixelBuffer?) {
        guard let cvBuffer = cvBuffer,
              let detector = detector else { return }
//        let ciImage = CIImage(cvPixelBuffer: cvBuffer)
//        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
//        guard let safeCGImage = cgImage else { return }
//        detector.calculateBlur(for: safeCGImage) { [weak self] score in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.images.append(Image(decorative: safeCGImage, scale: 1.0, orientation: .up))
//                guard let idx = self.images.indices.last else { return }
//                self.scores[idx] = score
//            }
//        }
        detector.calculateBlur(for: cvBuffer) { [weak self] score, laplacian in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let ciImage = CIImage(cvPixelBuffer: cvBuffer)
                let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)
                guard let safeCGImage = cgImage else { return }
                self.images.append(Image(decorative: safeCGImage, scale: 1.0, orientation: .up))
                guard let idx = self.images.indices.last else { return }
                self.scores[idx] = score
                if let laplacian = laplacian,
                   let cgLaplacian = self.context.createCGImage(laplacian, from: laplacian.extent) {
                    self.laplacians[idx] = Image(decorative: cgLaplacian, scale: 1.0, orientation: .up)
                }
            }
        }
//        CVPixelBufferLockBaseAddress(cvBuffer, .readOnly)
//        let ciImage = CIImage(cvPixelBuffer: cvBuffer)
//        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
//        let width = CVPixelBufferGetWidthOfPlane(cvBuffer, 0)
//        let height = CVPixelBufferGetHeightOfPlane(cvBuffer, 0)
//        let count = width * height
//
//        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(cvBuffer, 0)
//        let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(cvBuffer, 0)
//        let lumaCopy = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: MemoryLayout<UInt8>.alignment)
//        lumaCopy.copyMemory(from: lumaBaseAddress!, byteCount: count)
//        CVPixelBufferUnlockBaseAddress(cvBuffer, .readOnly)
//        guard let safeCGImage = cgImage else {
//            return
//        }
    }
}
