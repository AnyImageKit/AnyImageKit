//
//  PhotoEditingStack.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import CoreImage

protocol PhotoEditingStackDelegate: AnyObject {
    
    func editingStack(_ stack: PhotoEditingStack, needUpdatePreview edit: PhotoEditingStack.Edit)
}

final class PhotoEditingStack {
    
    weak var delegate: PhotoEditingStackDelegate?
    
    private(set) var edit: Edit = .init()
    
    // 以下字段是输出时用于计算的临时变量，不需要缓存
    var originImage: UIImage = .init()
    var mosaicImages: [UIImage] = []
    var originImageViewBounds: CGRect = .zero
    var cropRect: CGRect = .zero
    var cropImageViewFrame: CGRect = .zero
    
    private let identifier: String
    private let cache = CodableCacheTool(module: .editor(.default))
    private var drawer: [GraphicsDrawing] = []
    
    init(identifier: String) {
        self.identifier = identifier
        load()
    }
}

// MARK: - Save & Load
extension PhotoEditingStack {
    
    func save() {
        if identifier.isEmpty { return }
        cache.store(edit, forKey: identifier)
    }
    
    func load() {
        if identifier.isEmpty { return }
        if let model: Edit = cache.retrieveModel(forKey: identifier) {
            edit = model
        }
    }
}

// MARK: - Edit
extension PhotoEditingStack {
    
    struct Edit: Codable {
        
        var brushData: [BrushData] = []
        var mosaicData: [MosaicData] = []
        var cropData: CropData = .init()
        var textData: [TextData] = []
        var outputImageData: Data?
    }
    
    func setBrushData(_ dataList: [BrushData]) {
        edit.brushData = dataList
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
    
    func setMosaicData(_ dataList: [MosaicData]) {
        edit.mosaicData = dataList.filter { !$0.drawnPaths.isEmpty }
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
    
    func setCropData(_ data: CropData) {
        edit.cropData = data
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
    
    func addTextData(_ data: TextData) {
        edit.textData.append(data)
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
    
    func removeTextData(_ data: TextData) {
        if let idx = edit.textData.firstIndex(of: data) {
            edit.textData.remove(at: idx)
            delegate?.editingStack(self, needUpdatePreview: edit)
        }
    }
    
    func updateTextData(_ data: TextData) {
        if let idx = edit.textData.firstIndex(of: data) {
            edit.textData.remove(at: idx)
            edit.textData.append(data)
        }
    }
    
    func moveTextDataToTop(_ data: TextData) {
        if let idx = edit.textData.firstIndex(of: data) {
            edit.textData.remove(at: idx)
            edit.textData.append(data)
        }
    }
    
    func setOutputImage(_ image: UIImage) {
        guard let data = image.pngData() else { return }
        edit.outputImageData = data
    }
    
    func canvasUndo() {
        guard !edit.brushData.isEmpty else { return }
        edit.brushData.removeLast()
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
    
    func mosaicUndo() {
        guard let data = edit.mosaicData.last else { return }
        if data.drawnPaths.count == 1 {
            edit.mosaicData.removeLast()
        } else {
            var paths = data.drawnPaths
            paths.removeLast()
            edit.mosaicData[edit.mosaicData.count-1] = MosaicData(idx: data.idx, drawnPaths: paths)
        }
        delegate?.editingStack(self, needUpdatePreview: edit)
    }
}

extension PhotoEditingStack.Edit {
    
    var isEdited: Bool {
        return cropData.didCrop || cropData.rotateState != .portrait || !brushData.isEmpty || !mosaicData.isEmpty || !textData.isEmpty
    }
    
    var canvasCanUndo: Bool {
        return !brushData.isEmpty
    }
    
    var mosaicCanUndo: Bool {
        return !mosaicData.flatMap { $0.drawnPaths }.isEmpty
    }
}

extension PhotoEditingStack.Edit: Equatable {
    
    static func == (lhs: PhotoEditingStack.Edit, rhs: PhotoEditingStack.Edit) -> Bool {
        return lhs.brushData == rhs.brushData
            && lhs.mosaicData == rhs.mosaicData
            && lhs.cropData == rhs.cropData
            && lhs.textData == rhs.textData
            && lhs.outputImageData == rhs.outputImageData
    }
}


// MARK: - Output
extension PhotoEditingStack {
    
    private func prepareOutout() {
        drawer = []
        guard let sourceImage = CIImage(image: originImage) else { return }
        let imageSize = sourceImage.extent.size
        let size = originImageViewBounds.size
        let scale = imageSize.width / size.width
        
        // 先绘制马赛克，再绘制画笔，最后绘制文本
        edit.mosaicData.forEach { data in
            self.drawer.append(BlurredMask(paths: data.drawnPaths, scale: scale, blurImage: mosaicImages[data.idx]))
        }
        drawer.append(CanvasMask(paths: edit.brushData.map { $0.drawnPath }, scale: scale))
        edit.textData.forEach { data in
            self.drawer.append(TextMask(data: data, scale: scale))
        }
    }
    
    private func cropImage(_ image: UIImage) -> UIImage {
        guard let source = image.cgImage else { return image }
        let size = image.size
        let imageFrame = cropImageViewFrame
        
        var rect: CGRect = .zero
        rect.origin.x = (cropRect.origin.x - imageFrame.origin.x) / imageFrame.width * size.width
        rect.origin.y = (cropRect.origin.y - imageFrame.origin.y) / imageFrame.height * size.height
        rect.size.width = size.width * cropRect.width / imageFrame.width
        rect.size.height = size.height * cropRect.height / imageFrame.height
        
        guard let resultImage = source.cropping(to: rect) else { return image }
        return UIImage(cgImage: resultImage)
    }
    
    private func rotateImage(_ image: UIImage) -> UIImage {
        guard edit.cropData.rotateState != .portrait, let cgImage = getCGImage(image) else { return image }
        let radians = edit.cropData.rotateState.angle
        var newSize = CGRect(origin: .zero, size: image.size).applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        return UIGraphicsImageRenderer.init(size: newSize, format: getImageRendererFormat()).image { rendererContext in
            let context = rendererContext.cgContext
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            context.scaleBy(x: -1, y: 1)
            if radians != RotateState.upsideDown.angle {
                context.rotate(by: CGFloat(radians))
            }
            context.draw(cgImage, in: CGRect(x: -image.size.width/2, y: -image.size.height/2, width: image.size.width, height: image.size.height))
        }
    }
    
    func output() -> UIImage? {
        prepareOutout()
        guard let cgImage = getCGImage(originImage), let ciImage = CIImage(image: originImage) else { return nil }
        let canvasSize = ciImage.extent.size
        
        let image = UIGraphicsImageRenderer.init(size: canvasSize, format: getImageRendererFormat()).image { rendererContext in
            let context = rendererContext.cgContext
            
            // 绘制原图
            context.saveGState()
            context.translateBy(x: 0, y: canvasSize.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(cgImage, in: CGRect(origin: .zero, size: canvasSize))
            context.restoreGState()
            
            // 绘制马赛克 & 画笔 & 文本
            self.drawer.forEach {
                $0.draw(in: context, size: canvasSize)
            }
        }
        return rotateImage(cropImage(image))
    }
}

// MARK: - Helper
extension PhotoEditingStack {
    
    private func getImageRendererFormat() -> UIGraphicsImageRendererFormat {
        let format: UIGraphicsImageRendererFormat
        if #available(iOS 11.0, *) {
            format = UIGraphicsImageRendererFormat.preferred()
        } else {
            format = UIGraphicsImageRendererFormat.default()
        }
        format.scale = 1
        format.opaque = true
        if #available(iOS 12.0, *) {
            format.preferredRange = .extended
        } else {
            format.prefersExtendedRange = false
        }
        return format
    }
    
    private func getCGImage(_ image: UIImage) -> CGImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let ciContext = CIContext(options: [.useSoftwareRenderer : false, .highQualityDownsample : true])
        return ciContext.createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: ciImage.colorSpace ?? CGColorSpaceCreateDeviceRGB())
    }
}
