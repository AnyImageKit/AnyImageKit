//
//  StateableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol StateableResource {
    
    associatedtype Resource: IdentifiableResource
    
    var stater: AnyImageStater { get }
    var stateIdentifier: String { get }
    var state: ResourceState<Resource> { get nonmutating set }
}

enum ResourceState<Resource: IdentifiableResource>: Equatable {
    
    case normal
    case selected
    case edited
    case disabled(AnyResourceDisableCheckRule<Resource>)
    
    static func == (lhs: ResourceState<Resource>, rhs: ResourceState<Resource>) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal):
            return true
        case (.selected, .selected):
            return true
        case (.edited, .edited):
            return true
        case (.disabled, .disabled):
            return true
        default:
            return false
        }
    }
    
    var isNormal: Bool {
        switch self {
        case .normal:
            return true
        default:
            return false
        }
    }
    
    var isSelected: Bool {
        switch self {
        case .selected:
            return true
        default:
            return false
        }
    }
    
    var isEdited: Bool {
        switch self {
        case .edited:
            return true
        default:
            return false
        }
    }
    
    var isDisabled: Bool {
        switch self {
        case .disabled:
            return true
        default:
            return false
        }
    }
}

struct AnyResourceDisableCheckRule<Resource: IdentifiableResource> {
    
    typealias CheckResultCompletion = (Asset<Resource>) -> Bool
    typealias DisabledMessageCompletion = (Asset<Resource>) -> String
    
    private let checkResult: CheckResultCompletion
    private let disabledMessage: DisabledMessageCompletion
    
    init(checkResult: @escaping CheckResultCompletion, disabledMessage: @escaping DisabledMessageCompletion) {
        self.checkResult = checkResult
        self.disabledMessage = disabledMessage
    }
    
    func isDisabled(for asset: Asset<Resource>) -> Bool {
        return self.checkResult(asset)
    }
    
    func disabledMessage(for asset: Asset<Resource>) -> String {
        return self.disabledMessage(asset)
    }
}
