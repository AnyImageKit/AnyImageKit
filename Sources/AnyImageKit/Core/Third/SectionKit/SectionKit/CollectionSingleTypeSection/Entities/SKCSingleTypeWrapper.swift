//
//  File.swift
//  
//
//  Created by linhey on 2022/8/31.
//

#if canImport(UIKit)
import UIKit

public extension SKWrapper where Base: UICollectionViewCell & SKLoadViewProtocol & SKConfigurableView {
    static func wrapperToSingleTypeSection(@SectionArrayResultBuilder<Base.Model> builder: () -> [Base.Model]) -> SKCSingleTypeSection<Base> {
        .init(builder())
    }
    
    static func wrapperToSingleTypeSection(_ model: Base.Model) -> SKCSingleTypeSection<Base> {
        wrapperToSingleTypeSection([model])
    }
    
    static func wrapperToSingleTypeSection(_ models: [Base.Model]) -> SKCSingleTypeSection<Base> {
        .init(models)
    }
    
    static func wrapperToSingleTypeSection() -> SKCSingleTypeSection<Base> {
        wrapperToSingleTypeSection([] as [Base.Model])
    }
    
    static func wrapperToSingleTypeSection(_ tasks: [() -> Base.Model]) -> SKCSingleTypeSection<Base> {
        return wrapperToSingleTypeSection(tasks.map({ $0() }))
    }
    
    static func wrapperToSingleTypeSection(_ tasks: [() async throws -> Base.Model]) async throws -> SKCSingleTypeSection<Base> {
        var models = [Base.Model]()
        for task in tasks {
            models.append(try await task())
        }
        return wrapperToSingleTypeSection(models)
    }
    
    static func wrapperToSingleTypeSection(count: Int) -> SKCSingleTypeSection<Base> where Base.Model == Void {
        wrapperToSingleTypeSection(.init(repeating: (), count: count))
    }
}

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func wrapperToSingleTypeSection(@SectionArrayResultBuilder<Model> builder: () -> [Model]) -> SKCSingleTypeSection<Self> {
        .init(builder())
    }
    
    static func wrapperToSingleTypeSection(_ model: Model) -> SKCSingleTypeSection<Self> {
        wrapperToSingleTypeSection([model])
    }
    
    static func wrapperToSingleTypeSection(_ models: [Model]) -> SKCSingleTypeSection<Self> {
        .init(models)
    }
    
    static func wrapperToSingleTypeSection() -> SKCSingleTypeSection<Self> {
        wrapperToSingleTypeSection([] as [Model])
    }
    
    static func wrapperToSingleTypeSection(_ tasks: [() -> Self.Model]) -> SKCSingleTypeSection<Self> {
        return wrapperToSingleTypeSection(tasks.map({ $0() }))
    }
    
    static func wrapperToSingleTypeSection(_ tasks: [() async throws -> Model]) async throws -> SKCSingleTypeSection<Self> {
        var models = [Model]()
        for task in tasks {
            models.append(try await task())
        }
        return wrapperToSingleTypeSection(models)
    }
    
    static func wrapperToSingleTypeSection(count: Int) -> SKCSingleTypeSection<Self> where Model == Void {
        wrapperToSingleTypeSection(.init(repeating: (), count: count))
    }
    
}

#endif
