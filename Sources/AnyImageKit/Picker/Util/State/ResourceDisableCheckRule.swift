//
//  ResourceDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol ResourceDisableCheckRule: IdentifiableResource {
    
    associatedtype Resource: IdentifiableResource
    
    func isDisabled(for asset: Asset<Resource>) -> Bool
    func disabledMessage(for asset: Asset<Resource>) -> String
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
