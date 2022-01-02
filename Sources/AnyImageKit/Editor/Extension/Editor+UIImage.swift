//
//  Editor+UIImage.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/25.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    
    /// 生成马赛克图片
    /// 在 DEBUG 模式下耗时 1-3 秒左右，RELEASE 模式下耗时 0.02 秒左右
    /// - Parameter level: 一个点转为多少 level*level 的正方形
    func mosaicImage(level: Int) -> UIImage? {
        // 获取 BitmapData
        let pixelChannelCount = 4
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let imgRef = self.cgImage else { return nil }
        let width = imgRef.width
        let height = imgRef.height
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: width*pixelChannelCount,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(imgRef, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        guard let bitmapData = context?.data else { return nil }
        
        //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
        var pixel: [UInt8] = Array(repeating: 0, count: pixelChannelCount)
        var index = 0
        var preIndex = 0
        for i in 0..<height-1 {
            for j in 0..<width-1 {
                index = i * width + j
                if i % level == 0 {
                    if j % level == 0 {
                        memcpy(&pixel, bitmapData + pixelChannelCount * index, pixelChannelCount)
                    } else {
                        memcpy(bitmapData + pixelChannelCount * index, &pixel, pixelChannelCount)
                    }
                } else {
                    preIndex = (i-1) * width + j
                    memcpy(bitmapData + pixelChannelCount * index, bitmapData + pixelChannelCount * preIndex, pixelChannelCount)
                }
            }
        }
        let dataLength = width * height * pixelChannelCount
        let providerOptional = CGDataProvider(dataInfo: nil, data: bitmapData, size: dataLength) { (_, _, _) in
        }
        guard let provider = providerOptional else { return nil }

        // 创建要输出的图像
        guard let mosaicImageRef =
            CGImage(width: width,
                    height: height,
                    bitsPerComponent: bitsPerComponent,
                    bitsPerPixel: 32,
                    bytesPerRow: width * pixelChannelCount,
                    space: colorSpace,
                    bitmapInfo: CGBitmapInfo(rawValue: 1),
                    provider: provider,
                    decode: nil,
                    shouldInterpolate: false,
                    intent: .defaultIntent)
            else { return nil }
        let outputContext = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: width * pixelChannelCount,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        outputContext?.draw(mosaicImageRef, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        guard let resultImageRef = outputContext?.makeImage() else { return nil }
        let scale = UIScreen.main.scale
        let resultImage = UIImage(cgImage: resultImageRef, scale: scale, orientation: .up)
        return resultImage
    }
    
    /// 高斯模糊图像
    /// - Parameter context: 上下文
    /// - Parameter blur: 模糊度
    func gaussianImage(context: CIContext, blur: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blur, forKey: "inputRadius")
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        guard let outputImage = context.createCGImage(result, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: outputImage)
    }
}
