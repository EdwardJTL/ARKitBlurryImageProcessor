//
//  BlurDetector.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import Foundation
import CoreVideo

class BlurDetector: NSObject {
    let detector = MetalBlurDetector()

    func calculateBlur(for image: CVPixelBuffer, completionHandler: @escaping (Float) -> Void) {
        detector.calculateBlur(for: image, completionHandler: completionHandler)
    }
}
