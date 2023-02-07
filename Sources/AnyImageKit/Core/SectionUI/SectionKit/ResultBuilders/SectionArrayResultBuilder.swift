//
//  File.swift
//  
//
//  Created by linhey on 2022/9/2.
//

import Foundation

@resultBuilder
public class SectionArrayResultBuilder<Model> {
    
    public static func buildExpression(_ expression: () -> Model) -> [Model] {
        [expression()]
    }
    
    public static func buildExpression(_ expression: [Model]) -> [Model] {
        expression
    }
    
    public static func buildExpression(_ expression: Model) -> [Model] {
        return [expression]
    }
    
    public static func buildExpression(_ expression: ()) -> [Model] {
        return []
    }
    
    public static func buildEither(first component: [Model]) -> [Model] {
        return component
    }
    
    public static func buildEither(second component: [Model]) -> [Model] {
        return component
    }
    
    public static func buildOptional(_ component: [Model]?) -> [Model] {
        return component ?? []
    }
    
    public static func buildBlock(_ components: [Model]...) -> [Model] {
        buildArray(components)
    }
    
    public static func buildArray(_ components: [[Model]]) -> [Model] {
        Array(components.joined())
    }
    
    public static func buildLimitedAvailability(_ component: [Model]) -> [Model] {
        component
    }
    
}
