//
//  InjectionKey.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

protocol InjectionKey {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}

/**
 
 struct <#KeyName#>: InjectionKey {
     static var currentValue = <#Object#>()
 }

 extension InjectedValues {
     
     var <#Key#>: <#Object#> {
         get { Self[<#KeyName#>.self] }
         set { Self[<#KeyName#>.self] = newValue }
     }
 }

 @Injected(\.<#Key#>)
 var <#PropertyName#>
 
 */
