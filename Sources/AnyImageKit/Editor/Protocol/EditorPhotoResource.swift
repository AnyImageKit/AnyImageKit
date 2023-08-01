//
//  EditorPhotoResource.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

public protocol EditorPhotoResource {
    func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void)
}

extension UIImage: EditorPhotoResource {
    
    public func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void) {
        completion(.success(adjustImage(self)))
    }
}

extension URL: EditorPhotoResource {
    
    public func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void) {
        if self.isFileURL {
            do {
                let data = try Data(contentsOf: self)
                if let image = UIImage(data: data) {
                    completion(.success(adjustImage(image)))
                } else {
                    completion(.failure(.invalidImage))
                }
            } catch {
                _print(error.localizedDescription)
                completion(.failure(.invalidData))
            }
        } else {
            completion(.failure(.invalidURL))
        }
    }
}

extension PHAsset: EditorPhotoResource {
    
    public func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void) {
        guard mediaType == .image else {
            completion(.failure(.invalidMediaType))
            return
        }
        ExportTool.requestPhoto(for: self, options: .init(size: limitSize)) { [unowned self] (result, _) in
            switch result {
            case .success(let response):
                if !response.isDegraded {
                    completion(.success(self.adjustImage(response.image)))
                }
            case .failure(let error):
                completion(.failure(error))
                if error == .cannotFindInLocal {
                    self.loadImageFromNetwork(completion: completion)
                }
            }
        }
    }
    
    private func loadImageFromNetwork(completion: @escaping (Result<UIImage, AnyImageError>) -> Void) {
        ExportTool.requestPhotoData(for: self) { (result, _) in
            switch result {
            case .success(let response):
                guard let resizedImage = UIImage.resize(from: response.data, limitSize: self.limitSize) else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidData))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(self.adjustImage(resizedImage)))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private var limitSize: CGSize {
        var size = UIScreen.main.bounds.size
        size.width *= UIScreen.main.scale
        size.height *= UIScreen.main.scale
        return size
    }
}


extension EditorPhotoResource {

    /// Preprocess the images before starting editing.
    fileprivate func adjustImage(_ sourceImage: UIImage) -> UIImage {
        return fixOrientationAndRotateToUp(sourceImage)
    }
    
    /// Fix orientation and rotate the image to upright position
    private func fixOrientationAndRotateToUp(_ sourceImage: UIImage) -> UIImage {
        guard let imageRef = sourceImage.cgImage else {
            return sourceImage
        }
        
        var rotationAngle: CGFloat = 0.0
        var mirrored = false
        var imageSize = sourceImage.size
        var canvasSize = CGSize(width: imageRef.width, height: imageRef.height)
        
        // Get EXIF property information.
        if let imageData = sourceImage.jpegData(compressionQuality: 0.1),
           let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
           let exifProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
           let orientationValue = exifProperties[kCGImagePropertyTIFFOrientation as String] as? UInt32 {
            let orientation = CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
            rotationAngle = getRotationAngleFromImageOrientation(orientation)
            mirrored = orientation == .upMirrored || orientation == .downMirrored ||
                       orientation == .leftMirrored || orientation == .rightMirrored
            let isLandscapeMode = orientation == .left || orientation == .leftMirrored ||
                                  orientation == .right || orientation == .rightMirrored
            
            let newSize = CGRect(origin: .zero, size: sourceImage.size).applying(CGAffineTransform(rotationAngle: rotationAngle)).size
            canvasSize.width = floor(newSize.width)
            canvasSize.height = floor(newSize.height)
            canvasSize = canvasSize.reversed(isLandscapeMode)
            imageSize = imageSize.reversed(isLandscapeMode)
        }
        
        // Correcting image orientation
        let fixedImage = UIGraphicsImageRenderer.init(size: canvasSize, format: getImageRendererFormat()).image { rendererContext in
            let context = rendererContext.cgContext
            
            context.saveGState()
            context.translateBy(x: canvasSize.width/2, y: canvasSize.height/2)
            context.scaleBy(x: mirrored ? -1 : 1, y: -1)
            context.rotate(by: rotationAngle)
            context.draw(imageRef, in: CGRect(x: -imageSize.width/2, y: -imageSize.height/2, width: imageSize.width, height: imageSize.height))
            context.restoreGState()
        }
        
        return fixedImage
    }
    
    /// Read the EXIF properties and return the rotation angle of the image in radians.
    private func getRotationAngleFromImageOrientation(_ orientation: CGImagePropertyOrientation) -> CGFloat {
        let pi = CGFloat.pi
        switch orientation {
        case .up, .upMirrored:
            return 0.0
        case .down, .downMirrored:
            return pi
        case .left, .rightMirrored:
            return (pi / 2)
        case .right, .leftMirrored:
            return -(pi / 2)
        }
    }
    
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
}
