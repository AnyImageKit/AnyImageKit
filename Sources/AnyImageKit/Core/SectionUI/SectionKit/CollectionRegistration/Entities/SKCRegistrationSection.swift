//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class SKCRegistrationSection: SKCRegistrationSectionProtocol {
    
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    public var registrationSectionInjection: SKCRegistrationSectionInjection?
    public var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol]
    public var registrations: [any SKCCellRegistrationProtocol]
    
    public lazy var minimumLineSpacing: CGFloat = 0
    public lazy var minimumInteritemSpacing: CGFloat = 0
    public lazy var sectionInset: UIEdgeInsets = .zero
    
    public convenience init() {
        self.init([:], [])
    }
    
    public convenience init(@SKCRegistrationSectionBuilder builder: (() -> [SKCRegistrationSectionBuilderStore])) {
        self.init()
        self.apply(builder)
    }
    
    public init(_ supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol],
                _ registrations: [any SKCCellRegistrationProtocol]) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }

}

