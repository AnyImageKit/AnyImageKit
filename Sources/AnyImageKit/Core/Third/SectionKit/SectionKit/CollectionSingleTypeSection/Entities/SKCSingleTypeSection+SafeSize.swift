//
//  SKCellSafeSizeProviderKind.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import UIKit

public struct SKCCellFractionLayoutContext {
    
    public let limitSize: CGSize
    public let minimumInteritemSpacing: CGFloat
    
    public func count(of width: CGFloat) -> Int {
        guard limitSize.width > 0, width > 0 else {
            return 0
        }
        return Int((limitSize.width + minimumInteritemSpacing) / (width + minimumInteritemSpacing))
    }
    
    public func size(of value: CGFloat) -> CGSize {
        guard limitSize.width > 0, value > 0, value <= 1 else {
            return .zero
        }
        let count = floor(1 / value)
        let itemWidth = floor((limitSize.width - (count - 1) * minimumInteritemSpacing) / count)
        return CGSize(width: itemWidth, height: limitSize.height)
    }
}

/// 提供 Cell - preferredSize(limit size: CGSize, model: Model?) 中 limit size 的值
public enum SKCellSafeSizeProviderKind {
    /// 使用默认的 safeSizeProvider 提供者尺寸
    case `default`
    /// 使用固定的 CGSize 来提供尺寸
    case fixed(CGSize)
    /// 根据比例来计算尺寸
    case fraction((_ context: SKCCellFractionLayoutContext) -> Double)
    case router(() -> SKCellSafeSizeProviderKind)

    public static func fraction(_ value: Double) -> SKCellSafeSizeProviderKind {
        .fraction { _ in value }
    }
}

/// 提供 Cell - preferredSize(limit size: CGSize, model: Model?) 中 limit size 的值
public enum SKSupplementarySafeSizeProviderKind {
    /// 使用默认的 safeSizeProvider 提供者尺寸
    case `default`
    case apple
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func supplementarySafeSize(_ kind: SKSupplementaryKind, _ providerKind: SKSupplementarySafeSizeProviderKind) -> Self {
        return supplementarySafeSize([kind], providerKind)
    }
    
    @discardableResult
    func supplementarySafeSize(_ kinds: [SKSupplementaryKind], _ providerKind: SKSupplementarySafeSizeProviderKind) -> Self {
        for kind in kinds {
            switch providerKind {
            case .apple:
                safeSize(kind, .init(block: { [weak self] in
                    guard let sectionView = self?.sectionView else { return .zero }
                    return sectionView.bounds.size
                }))
            case .default:
                safeSize(kind, nil)
            }
        }
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func cellSafeSize(_ provider: SKSafeSizeProvider) -> Self {
        return safeSize(.cell, provider)
    }
    
    @discardableResult
    func cellSafeSize(_ kind: SKCellSafeSizeProviderKind, transforms: SKSafeSizeTransform) -> Self {
        cellSafeSize(kind, transforms: [transforms])
    }
    
    @discardableResult
    func cellSafeSize(_ kind: SKCellSafeSizeProviderKind, transforms: [SKSafeSizeTransform] = []) -> Self {
        func transform(size: CGSize) -> CGSize {
            return transforms.reduce(into: size, { $0 = $1.transform($0) })
        }
        
        switch kind {
        case .fixed(let size):
            return self.cellSafeSize(.init(block: {
                return transform(size: size)
            }))
        case .router(let router):
            return self.cellSafeSize(router(), transforms: transforms)
        case .default:
            return self.cellSafeSize(.init(block: { [weak self] in
                guard let self = self else { return .zero }
                let size = self.safeSizeProvider.size
                return transform(size: size)
            }))
        case .fraction(let block):
            return self.cellSafeSize(.init(block: { [weak self] in
                guard let self = self else { return .zero }
                let context = SKCCellFractionLayoutContext(limitSize: safeSizeProvider.size,
                                                           minimumInteritemSpacing: minimumInteritemSpacing)
                let value = block(context)
                let newSize = context.size(of: value)
                return transform(size: newSize)
            }))
        }
    }
    
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func safeSize(_ kind: SKSupplementaryKind, _ provider: SKSafeSizeProvider?) -> Self {
        safeSizeProviders[kind] = provider
        return self
    }

    @discardableResult
    func safeSize(_ provider: SKSafeSizeProvider) -> Self {
        safeSizeProvider = provider
        return self
    }
    
    @discardableResult
    func safeSize(_ path: KeyPath<SKCSingleTypeSection, SKSafeSizeProvider>) -> Self {
        return safeSize(self[keyPath: path])
    }
    
    @discardableResult
    func safeSize<Root>(_ path: KeyPath<Root, SKSafeSizeProvider>, on object: Root) -> Self {
        return safeSize(object[keyPath: path])
    }
    
}
