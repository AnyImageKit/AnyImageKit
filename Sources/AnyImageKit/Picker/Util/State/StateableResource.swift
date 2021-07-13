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
    
    var stater: AnyImageStater<Resource> { get }
    var stateIdentifier: String { get }
    var state: ResourceState<Resource> { get nonmutating set }
    var disableCheckRules: [AnyResourceDisableCheckRule<Resource>] { get nonmutating set }
}

extension StateableResource {
    
    var state: ResourceState<Resource> {
        get {
            stater.loadState(key: stateIdentifier)
        }
        nonmutating set {
            stater.updateState(newValue, key: stateIdentifier)
        }
    }
    
    var disableCheckRules: [AnyResourceDisableCheckRule<Resource>] {
        get {
            return stater.disableCheckRules
        }
        set {
            stater.disableCheckRules = newValue
        }
    }
}

enum ResourceState<Resource: IdentifiableResource>: Equatable {
    
    case initialize
    case normal
    case selected
    case edited
    case disabled(AnyResourceDisableCheckRule<Resource>)
    
    var isDisabled: Bool {
        switch self {
        case .disabled:
            return true
        default:
            return false
        }
    }
}

public struct AnyResourceDisableCheckRule<Resource: IdentifiableResource>: IdentifiableResource, ResourceDisableCheckRule {
    
    public typealias CheckResultCompletion = (Asset<Resource>) -> Bool
    public typealias DisabledMessageCompletion = (Asset<Resource>) -> String
    
    public let identifier: String
    
    private let checkResult: CheckResultCompletion
    private let disabledMessage: DisabledMessageCompletion
    
    public init(identifier: String, checkResult: @escaping CheckResultCompletion, disabledMessage: @escaping DisabledMessageCompletion) {
        self.identifier = identifier
        self.checkResult = checkResult
        self.disabledMessage = disabledMessage
    }
    
    public init<Rule: ResourceDisableCheckRule>(_ rule: Rule) where Rule.Resource == Resource {
        self.init(identifier: rule.identifier) { asset in
            rule.isDisabled(for: asset)
        } disabledMessage: { asset in
            rule.disabledMessage(for: asset)
        }
    }
    
    public func isDisabled(for asset: Asset<Resource>) -> Bool {
        return self.checkResult(asset)
    }
    
    public func disabledMessage(for asset: Asset<Resource>) -> String {
        return self.disabledMessage(asset)
    }
}

public protocol ResourceDisableCheckRule: IdentifiableResource {
    
    associatedtype Resource: IdentifiableResource
    
    func isDisabled(for asset: Asset<Resource>) -> Bool
    func disabledMessage(for asset: Asset<Resource>) -> String
}
