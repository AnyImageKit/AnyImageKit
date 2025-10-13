//
//  File.swift
//  
//
//  Created by linhey on 2024/6/28.
//

import Foundation
import UIKit

public protocol SKCSingleTypeCellActionContextProtocol {
    associatedtype Cell: SKConfigurableView & SKLoadViewProtocol & UICollectionViewCell
    var section: SKCSingleTypeSection<Cell> { get }
    var row: Int { get }
    var model: Cell.Model { get }
}

public extension SKCSingleTypeCellActionContextProtocol {
    
    func reload() {
        section.refresh(at: row)
    }
    
    func reload(with model: Cell.Model) {
        refresh(with: model)
    }
    
    func refresh(with model: Cell.Model) {
        section.refresh(with: .init(row: row, model: model))
    }

    func remove() {
        section.remove(row)
    }
    
    func delete() {
        section.delete(row)
    }

    func insert(before model: Cell.Model) {
        insert(after: [model])
    }
    
    func insert(before model: [Cell.Model]) {
        section.insert(at: row, model)
    }
    
    func insert(after model: Cell.Model) {
        insert(after: [model])
    }
    
    func insert(after model: [Cell.Model]) {
        section.insert(at: row + 1, model)
    }
    
}
