//
//  File.swift
//  
//
//  Created by linhey on 2022/8/15.
//

import UIKit

public extension Array where Element: SKCCellRegistrationProtocol {
        
    func shouldHighlight(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldHighlight(block) }
    }
    
    func onHighlight(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onHighlight(block) }
    }
    
    func onUnhighlight(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onUnhighlight(block) }
    }
    
    func shouldSelect(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldSelect(block) }
    }
    
    func shouldDeselect(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldDeselect(block) }
    }
    
    func onSelected(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onSelected(block) }
    }
    
    func onDeselected(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onDeselected(block) }
    }
    
    func canPerformPrimaryAction(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canPerformPrimaryAction(block) }
    }
    
    func onPerformPrimaryAction(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onPerformPrimaryAction(block) }
    }
    
    func onWillDisplay(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onWillDisplay(block) }
    }
    
    func onEndDisplaying(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onEndDisplaying(block) }
    }
    
    func canFocus(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canFocus(block) }
    }
    
    func selectionFollowsFocus(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.selectionFollowsFocus(block) }
    }
    
    func canEdit(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canEdit(block) }
    }
    
    func shouldSpringLoad(_ block: @escaping (_ model: Element.View.Model, _ context: UISpringLoadedInteractionContext) -> Bool) -> Self {
        return self.map { $0.shouldSpringLoad(block) }
    }
    
    func shouldBeginMultipleSelectionInteraction(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldBeginMultipleSelectionInteraction(block) }
    }
    
    func onBeginMultipleSelectionInteraction(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onBeginMultipleSelectionInteraction(block) }
    }
    
}
