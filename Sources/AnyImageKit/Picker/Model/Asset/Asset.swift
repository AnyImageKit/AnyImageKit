//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

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

// MARK: CustomStringConvertible
extension Asset: CustomStringConvertible {
    
    public var description: String {
        "Asset<\(Resource.self)> id=\(identifier) mediaType=\(mediaType)\n"
    }
}
