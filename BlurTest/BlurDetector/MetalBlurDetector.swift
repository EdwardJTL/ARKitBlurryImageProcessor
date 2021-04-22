//
//  MetalBlurDetector.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import CoreVideo
import Foundation
import Metal
import MetalKit
import MetalPerformanceShaders

class MetalBlurDetector {
    var cvTextureCache: CVMetalTextureCache?
    var metalDevice: MTLDevice?
    var metalCommandQueue: MTLCommandQueue?
    var laplacian: MPSUnaryImageKernel
    var meanAndVariance: MPSUnaryImageKernel

    init() {
        metalDevice = MTLCreateSystemDefaultDevice()
        guard let metalDevice = metalDevice else {
            fatalError("Unable to create metal device")
        }
        let cacheSuccess = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &cvTextureCache)
        if cacheSuccess != kCVReturnSuccess {
            fatalError("Cache creation failed with \(cacheSuccess)")
        }
        metalCommandQueue = metalDevice.makeCommandQueue()
        laplacian = MPSImageLaplacian(device: metalDevice)
        meanAndVariance = MPSImageStatisticsMeanAndVariance(device: metalDevice)
    }

    func calculateBlur(for imageBuffer: CVPixelBuffer, completionHandler: @escaping (Float) -> Void) {
        if CVPixelBufferGetPlaneCount(imageBuffer) < 2 {
            completionHandler(-1)
            return
        }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var score: Float = -1
            defer { completionHandler(score) }
            guard let self = self,
                  let mtlDevice = self.metalDevice,
                  let mtlQueue = self.metalCommandQueue else { return }

            let mtlTexture: MTLTexture? = self.createGrayScaleTexture(from: imageBuffer)
            guard let safeMTLTexture = mtlTexture else { return }

            let commandBuffer = mtlQueue.makeCommandBuffer()
            guard let safeCommandBuffer = commandBuffer else { return }

            let lapDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: safeMTLTexture.pixelFormat,
                                                                   width: safeMTLTexture.width, height: safeMTLTexture.height,
                                                                   mipmapped: false)
            lapDesc.usage = [.shaderWrite, .shaderRead]
            let lapTex = mtlDevice.makeTexture(descriptor: lapDesc)
            guard let safeLapTex = lapTex else { return }
            self.laplacian.encode(commandBuffer: safeCommandBuffer, sourceTexture: safeMTLTexture, destinationTexture: safeLapTex)

            let varianceTexDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: safeMTLTexture.pixelFormat,
                                                                           width: 2, height: 1,
                                                                           mipmapped: false)
            varianceTexDesc.usage = [.shaderWrite, .shaderRead]
            let varianceTex = mtlDevice.makeTexture(descriptor: varianceTexDesc)
            guard let safeVarianceTex = varianceTex else { return }
            self.meanAndVariance.encode(commandBuffer: safeCommandBuffer, sourceTexture: safeMTLTexture, destinationTexture: safeVarianceTex)

            safeCommandBuffer.commit()
            safeCommandBuffer.waitUntilCompleted()

            var result = [Int8](repeating: 0, count: 2)
            let region = MTLRegionMake2D(0, 0, 2, 1)
            varianceTex?.getBytes(&result, bytesPerRow: 1 * 2 * 4, from: region, mipmapLevel: 0)
            print(result)

            score = Float(result[1])
            return
        }
    }

    func createGrayScaleTexture(from imageBuffer: CVPixelBuffer) -> MTLTexture? {
        guard let cvTextureCache = self.cvTextureCache else { return nil }
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        }
        var mtlTexture: MTLTexture? = nil
        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               cvTextureCache,
                                                               imageBuffer,
                                                               nil,
                                                               .r8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &texture)
        if status == kCVReturnSuccess,
           let texture = texture {
            mtlTexture = CVMetalTextureGetTexture(texture)
        }
        return mtlTexture
    }
}
