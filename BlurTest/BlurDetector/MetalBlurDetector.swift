//
//  MetalBlurDetector.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import CoreVideo
import Foundation

class MetalBlurDetector {
    func calculateBlur(for image: CVPixelBuffer, completionHandler: @escaping (Float) -> Void) {
        completionHandler(10)
    }
}
