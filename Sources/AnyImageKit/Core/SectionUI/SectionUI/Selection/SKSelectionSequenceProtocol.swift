//
//  File.swift
//  
//
//  Created by linhey on 2022/9/8.
//

import Foundation

public protocol SKSelectionSequenceProtocol {
    
    associatedtype Element: SKSelectionProtocol
    
    /// 可选元素序列
    var selectableElements: [Element] { get }
    
    /// 已选中某个元素
    /// - Parameters:
    ///   - index: 选中元素索引
    ///   - element: 选中元素
    func element(selected index: Int, element: Element)
    
    /// 取消选中某个元素
    /// - Parameters:
    ///   - index: 选中元素索引
    ///   - element: 选中元素
    func element(deselected index: Int, element: Element)
    
}

public extension SKSelectionSequenceProtocol {
    func element(selected: Int, element: Element) {}
    func element(deselected: Int, element: Element) {}
}

public extension SKSelectionSequenceProtocol {
    /// 序列中第一个选中的元素
    func firstSelectedElement() -> Element? {
        return selectableElements.first(where: { $0.isSelected })
    }
    
    /// 序列中第一个选中的元素的索引
    func firstSelectedIndex() -> Int? {
        return selectableElements.firstIndex(where: { $0.isSelected })
    }
    
    /// 已选中的元素
    var selectedElements: [Element] {
        selectableElements.filter(\.isSelected)
    }
    
    /// 已选中的元素序列
    var selectedIndexs: [Int] {
        selectableElements.enumerated().filter { $0.element.isSelected }.map(\.offset)
    }
    
    /// 选中元素
    /// - Parameters:
    ///   - index: 选择序号
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    ///   - needInvert: 是否需要支持反选操作 | default: false
    func select(at index: Int, isUnique: Bool, needInvert: Bool) {
        guard selectableElements.indices.contains(index) else {
            return
        }
        
        guard isUnique else {
            let element = selectableElements[index]
            guard needInvert, element.isSelected else {
                select(at: index)
                return
            }
            deselect(at: index)
            return
        }
        
        for offset in selectableElements.indices {
            guard offset == index else {
                deselect(at: offset)
                continue
            }
            let element = selectableElements[offset]
            guard needInvert, element.isSelected else {
                select(at: offset)
                continue
            }
            deselect(at: offset)
        }
    }
    
    /// 取消选中指定序号的元素
    /// - Parameter index: 指定序号
    func select(at index: Int) {
        let element = selectableElements[index]
        guard element.isEnabled,
              element.canSelect,
              !element.isSelected else {
            return
        }
        
        element.isSelected = true
        self.element(selected: index, element: element)
    }
    
    /// 取消选中指定序号的元素
    /// - Parameter index: 指定序号
    func deselect(at index: Int) {
        let element = selectableElements[index]
        guard element.isEnabled,
              element.isSelected else {
            return
        }
        element.isSelected = false
        self.element(deselected: index, element: element)
    }
    
    /// 选中所有的元素
    func selectAll() {
        selectedElements.indices.forEach { index in
            select(at: index)
        }
    }
    
    /// 取消选中所有的元素
    func deselectAll() {
        selectedElements.indices.forEach { index in
            deselect(at: index)
        }
    }
    
}
