//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import CoreGraphics

/// A wapper for manage Real Resource
public struct Asset<Resource: IdentifiableResource>: CheckableResource {
    
    public let resource: Resource
    public let mediaType: MediaType
    
    /// Manage/Store states
    ///
    /// Checker is create/shared by AssetCollection, for asset, it's read only
    unowned let checker: AssetChecker<Resource>
    
    init(resource: Resource, mediaType: MediaType, checker: AssetChecker<Resource>) {
        self.resource = resource
        self.mediaType = mediaType
        self.checker = checker
    }
}

// MARK: IdentifiableResource
extension Asset: IdentifiableResource {
    
    public var identifier: String {
        resource.identifier
    }
}

// MARK: LoadableResource
extension Asset: LoadableResource where Resource: LoadableResource {
    
    static var preferredMaximumSize: CGSize {
        Resource.preferredMaximumSize
    }
    
    func loadImage(options: ResourceLoadOptions = preferredOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadImage(options: options)
    }
    
    func loadImageData(options: ResourceLoadOptions = preferredOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadImageData(options: options)
    }
    
    func loadLivePhoto(options: ResourceLoadOptions = preferredOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadLivePhoto(options: options)
    }
    
    func loadGIF(options: ResourceLoadOptions = preferredOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadGIF(options: options)
    }
    
    func loadVideo(options: ResourceLoadOptions = preferredOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadVideo(options: options)
    }
}

// MARK: State
extension Asset {
    
    var selectedNum: Int {
        checker.selectedNumber(asset: self) ?? 1
    }
    
    var state: AssetState<Resource> {
        checker.loadState(asset: self)
    }
    
    var isNormal: Bool {
        state.isNormal
    }
    
    var isSelected: Bool {
        state.isSelected
    }
    
    var isDisabled: Bool {
        state.isDisabled
    }
}

// MARK: Edit
extension Asset {
    
    
}

// MARK: CustomStringConvertible
extension Asset: CustomStringConvertible {
    
    public var description: String {
        "Asset<\(Resource.self)> id=\(identifier) mediaType=\(mediaType)\n"
    }
}
