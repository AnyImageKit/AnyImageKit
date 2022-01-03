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
        completion(.success(self))
    }
}

extension URL: EditorPhotoResource {
    
    public func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void) {
        if self.isFileURL {
            do {
                let data = try Data(contentsOf: self)
                if let image = UIImage(data: data) {
                    completion(.success(image))
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
        ExportTool.requestPhoto(for: self, options: .init(size: limitSize)) { [weak self] (result, _) in
            switch result {
            case .success(let response):
                if !response.isDegraded {
                    completion(.success(response.image))
                }
            case .failure(let error):
                completion(.failure(error))
                if error == .cannotFindInLocal {
                    self?.loadImageFromNetwork(completion: completion)
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
