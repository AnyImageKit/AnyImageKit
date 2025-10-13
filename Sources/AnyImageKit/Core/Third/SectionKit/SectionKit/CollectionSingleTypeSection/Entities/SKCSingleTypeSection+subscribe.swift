//
//  File.swift
//  
//
//  Created by linhey on 2023/7/25.
//

import Foundation
import Combine

// Data source subscription
public extension SKCSingleTypeSection {
    
    @discardableResult
    func subscribe(models publisher: some Publisher<[Model], Never>) -> Self {
        publishers.modelsCancellable = publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] models in
            self?.apply(models)
        }
        return self
    }
    
    @discardableResult
    func subscribe(models publisher: some Publisher<Model, Never>) -> Self {
        return subscribe(models: publisher.map({ [$0] }))
    }
    
    @discardableResult
    func subscribe(models publisher: some Publisher<Model?, Never>) -> Self {
        return subscribe(models: publisher.map({ model in
            if let model = model {
                return [model]
            } else {
                return []
            }
        }))
    }
    
    @available(*, deprecated, message: "use subscribe(models:) instead")
    @discardableResult
    func subscribe<Output>(models publisher: some Publisher<[Output], Never>, convert: @escaping (Output) -> Model?) -> Self {
        return subscribe(models: publisher.map({ list in
            list.compactMap(convert)
        }))
    }
    
    @available(*, deprecated, message: "use subscribe(models:) instead")
    @discardableResult
    func subscribe(models publisher: some Publisher<[Model]?, Never>) -> Self {
        return subscribe(models: publisher.map({ $0 ?? [] }))
    }
    
}
