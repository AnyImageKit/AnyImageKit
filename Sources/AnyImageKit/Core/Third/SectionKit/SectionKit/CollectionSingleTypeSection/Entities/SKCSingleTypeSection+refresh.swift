//
//  File.swift
//
//
//  Created by linhey on 2023/7/25.
//

import Foundation

// Public extension for SKCSingleTypeSection to add refresh functionality
public extension SKCSingleTypeSection {
    
    /// Refreshes the section at the specified row index.
    /// - Parameter row: The index of the row to refresh.
    func refresh(at row: Int) {
        refresh(at: [row])
    }
    
    /// Refreshes the section at the specified row indices.
    /// - Parameter row: An array of row indices to refresh.
    func refresh(at row: [Int]) {
        sectionInjection?.reload(cell: row)
    }
    
}

// Public extension for SKCSingleTypeSection to add specific update functionality
public extension SKCSingleTypeSection {
    
    /// A struct representing a payload for refreshing a specific row.
    struct RefreshPayload {
        public var row: Int
        public var model: Model
        public init(row: Int, model: Model) {
            self.row = row
            self.model = model
        }
    }
    
    func refresh(at row: Int, model: Model) {
        refresh(with: .init(row: row, model: model))
    }
    
    func refresh(with payloads: RefreshPayload) {
        refresh(with: [payloads])
    }

    /// Refreshes the section with the provided payloads.
    /// - Parameter payloads: An array of RefreshPayload to update the section.
    func refresh(with payloads: [RefreshPayload]) {
        #if DEBUG
        for payload in payloads {
            if self.validate(payload: payload) == false {
                assertionFailure("刷新数据越界")
            }
        }
        #endif
        let payloads = payloads.filter(validate(payload:))
        for payload in payloads {
            models[payload.row] = payload.model
        }
        guard !payloads.isEmpty else {
            return
        }
        refresh(at: payloads.map(\.row))
    }
    
    /// Refreshes the section with the provided models based on a predicate.
    /// - Parameters:
    ///   - models: An array of new models to refresh the section with.
    ///   - predicate: A closure that takes two models and returns a Boolean value indicating whether they match.
    func refresh(_ models: [Model], predicate: (_ lhs: Model, _ rhs: Model) -> Bool) {
        var store = [Int: RefreshPayload]()
        for (index, old) in self.models.enumerated() {
            if store[index] != nil { continue }
            for new in models {
                if predicate(old,new) {
                    store[index] = RefreshPayload(row: index, model: new)
                }
            }
        }
        refresh(with: store.map(\.value))
    }
    
    /// Refreshes the section with a single equatable model.
    /// - Parameter model: The model to refresh the section with.
    func refresh(_ model: Model) where Model: Equatable {
        self.refresh([model])
    }

    /// Refreshes the section with an array of equatable models.
    /// - Parameter models: An array of models to refresh the section with.
    func refresh(_ models: [Model]) where Model: Equatable {
        refresh(models, predicate: ==)
    }
    
    /// Refreshes the section with a single equatable model.
    /// - Parameter model: The model to refresh the section with.
    func refresh(_ model: Model) where Model: Equatable & AnyObject {
        self.refresh([model])
    }

    /// Refreshes the section with an array of equatable models.
    /// - Parameter models: An array of models to refresh the section with.
    func refresh(_ models: [Model]) where Model: Equatable & AnyObject {
        refresh(models, predicate: ==)
    }
    
    /// Refreshes the section with a single model conforming to AnyObject.
    /// - Parameter model: The model to refresh the section with.
    func refresh(_ model: Model) where Model: AnyObject {
        self.refresh([model])
    }
    
    /// Refreshes the section with an array of models conforming to AnyObject.
    /// - Parameter models: An array of models to refresh the section with.
    func refresh(_ models: [Model]) where Model: AnyObject {
        refresh(models, predicate: ===)
    }
    
}

// Extension for SKCSingleTypeSection to add private validation functionality
private extension SKCSingleTypeSection {
    
    /// Validates if the provided payload's row index exists within the models array.
    /// - Parameter payload: The RefreshPayload containing the row index to validate.
    /// - Returns: A Boolean value indicating whether the row index is valid.
    func validate(payload: RefreshPayload) -> Bool {
        models.indices.contains(payload.row)
    }
    
}
