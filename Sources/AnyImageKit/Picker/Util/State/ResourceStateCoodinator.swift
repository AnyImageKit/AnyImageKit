//
//  ResourceStateCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol ResourceStateCoodinator: IdentifiableResource {
    
    associatedtype Resource: LoadableResource
    
    var resource: Resource { get }
    var state: ResourceState<Resource> { get nonmutating set }
    var disableCheckRules: [AnyResourceDisableCheckRule<Resource>] { get nonmutating set }
}
