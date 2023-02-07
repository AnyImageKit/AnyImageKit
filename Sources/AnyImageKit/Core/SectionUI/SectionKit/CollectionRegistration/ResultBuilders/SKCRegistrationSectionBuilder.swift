//
//  File.swift
//  
//
//  Created by linhey on 2022/9/2.
//

import UIKit
import CoreTransferable

public enum SKCRegistrationSectionBuilderStore {
    case supplementary(any SKCSupplementaryRegistrationProtocol)
    case registration(any SKCCellRegistrationProtocol)
}

@resultBuilder
public class SKCRegistrationSectionBuilder: SectionArrayResultBuilder<SKCRegistrationSectionBuilderStore> {
    
    public static func buildExpression(_ expression: () -> any SKCSupplementaryRegistrationProtocol) -> [SKCRegistrationSectionBuilderStore] {
        [.supplementary(expression())]
    }
    
    public static func buildExpression(_ expression: any SKCSupplementaryRegistrationProtocol) -> [SKCRegistrationSectionBuilderStore] {
        [.supplementary(expression)]
    }
    
    public static func buildExpression(_ expression: [any SKCSupplementaryRegistrationProtocol]) -> [SKCRegistrationSectionBuilderStore] {
        expression.map({ .supplementary($0) })
    }
    
    public static func buildExpression(_ expression: () -> any SKCCellRegistrationProtocol) -> [SKCRegistrationSectionBuilderStore] {
        [.registration(expression())]
    }
    
    public static func buildExpression(_ expression: any SKCCellRegistrationProtocol) -> [SKCRegistrationSectionBuilderStore] {
        [.registration(expression)]
    }
    
    public static func buildExpression(_ expression: [any SKCCellRegistrationProtocol]) -> [SKCRegistrationSectionBuilderStore] {
        expression.map({ .registration($0) })
    }
    
}
