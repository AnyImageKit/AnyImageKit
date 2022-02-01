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
    
    func loadImage() async throws -> UIImage
}

extension UIImage: EditorPhotoResource {
    
    public func loadImage() async throws -> UIImage {
        return self
    }
}

extension URL: EditorPhotoResource {
    
    public func loadImage() async throws -> UIImage {
        if self.isFileURL {
            do {
                let data = try Data(contentsOf: self)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw AnyImageError.invalidImage
                }
            } catch {
                _print(error.localizedDescription)
                throw AnyImageError.invalidData
            }
        } else {
            throw AnyImageError.invalidURL
        }
    }
}

extension PHAsset: EditorPhotoResource {
    
    public func loadImage() async throws -> UIImage {
        guard mediaType == .image else {
            throw AnyImageError.invalidMediaType
        }
        return try await withCheckedThrowingContinuation { continuation in
            ExportTool.requestPhoto(for: self, options: .init(size: limitSize)) { [weak self] (result, _) in
                switch result {
                case .success(let response):
                    if !response.isDegraded {
                        continuation.resume(returning: response.image)
                    }
                case .failure(let error):
                    if error == .cannotFindInLocal {
                        self?.loadImageFromNetwork(completion: { result in
                            switch result {
                            case .success(let image):
                                continuation.resume(returning: image)
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        })
                    }
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
                    completion(.success(resizedImage))
                }
            case .failure(let error):
                completion(.failure(error))
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
