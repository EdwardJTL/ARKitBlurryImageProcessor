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

    func calculateBlur(for cgImage: CGImage, completionHandler: @escaping (Float, CIImage?) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var score: Float = -1
            var image: CIImage?
            defer { completionHandler(score, image) }
            guard let self = self else { return }
            if let mtlTexture = self.createFullColorTexture(from: cgImage) {
                let (variance, laplacian) = self.calculateBlur(from: mtlTexture)
                score = Float(variance ?? -1)
                image = laplacian
            }
            return
        }
    }

    func calculateBlur(for imageBuffer: CVPixelBuffer, completionHandler: @escaping (Float, CIImage?) -> Void) {
        if CVPixelBufferGetPlaneCount(imageBuffer) < 2 {
            completionHandler(-1, nil)
            return
        }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var score: Float = -1
            var image: CIImage?
            defer { completionHandler(score, image) }
            guard let self = self else { return }

            if let mtlTexture = self.createGrayScaleTexture(from: imageBuffer) {
                let (variance, laplacian) = self.calculateBlur(from: mtlTexture)
                score = Float(variance ?? -1)
                image = laplacian
            }
            return
        }
    }

    func calculateBlur(from texture: MTLTexture) -> (Int8?, CIImage?) {
        guard let mtlDevice = metalDevice, let mtlQueue = metalCommandQueue else { return (nil, nil) }

        let commandBuffer = mtlQueue.makeCommandBuffer()
        guard let safeCommandBuffer = commandBuffer else { return (nil, nil) }

        let lapDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat,
                                                               width: texture.width, height: texture.height,
                                                               mipmapped: false)
        lapDesc.usage = [.shaderWrite, .shaderRead]
        let lapTex = mtlDevice.makeTexture(descriptor: lapDesc)
        guard let safeLapTex = lapTex else { return (nil, nil)}
        laplacian.encode(commandBuffer: safeCommandBuffer, sourceTexture: texture, destinationTexture: safeLapTex)

        let varianceTexDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat,
                                                                       width: 2, height: 1,
                                                                       mipmapped: false)
        varianceTexDesc.usage = [.shaderWrite, .shaderRead]
        let varianceTex = mtlDevice.makeTexture(descriptor: varianceTexDesc)
        guard let safeVarianceTex = varianceTex else { return (nil, nil) }
        self.meanAndVariance.encode(commandBuffer: safeCommandBuffer, sourceTexture: safeLapTex, destinationTexture: safeVarianceTex)

        safeCommandBuffer.commit()
        safeCommandBuffer.waitUntilCompleted()

        var result = [Int8](repeating: 0, count: 2)
        let region = MTLRegionMake2D(0, 0, 2, 1)
        varianceTex?.getBytes(&result, bytesPerRow: 1 * 2 * 4, from: region, mipmapLevel: 0)
        print(result)

        let kciOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceGray(),
                          CIContextOption.outputPremultiplied: true,
                          CIContextOption.useSoftwareRenderer: false] as? [CIImageOption: Any]

        return (result.last, CIImage(mtlTexture: safeLapTex, options: kciOptions))
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

    func createFullColorTexture(from cgImage: CGImage) -> MTLTexture? {
        guard let device = metalDevice else { return nil }
        let textureLoader = MTKTextureLoader(device: device)
        do {
            return try textureLoader.newTexture(cgImage: cgImage, options: nil)
        } catch {
            print("Error loading texture \(error)")
            return nil
        }
    }
}
