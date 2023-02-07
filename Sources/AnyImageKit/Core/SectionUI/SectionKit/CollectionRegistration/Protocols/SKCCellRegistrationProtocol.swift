//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol SKCCellRegistrationProtocol: SKCSupplementaryRegistrationProtocol where View: UICollectionViewCell {
    
    var shouldHighlight: BoolBlock? { get set }
    var shouldSelect: BoolBlock? { get set }
    var shouldDeselect: BoolBlock? { get set }
    var canPerformPrimaryAction: BoolBlock? { get set }
    var canFocus: BoolBlock? { get set }
    var selectionFollowsFocus: BoolBlock? { get set }
    var canEdit: BoolBlock? { get set }
    var shouldBeginMultipleSelectionInteraction: BoolBlock? { get set }
    
    var onHighlight: VoidBlock? { get set }
    var onUnhighlight: VoidBlock? { get set }
    var onSelected: VoidBlock? { get set }
    var onDeselected: VoidBlock? { get set }
    var onPerformPrimaryAction: VoidBlock? { get set }
    var onBeginMultipleSelectionInteraction: VoidBlock? { get set }
    
    var onWillDisplay: VoidBlock? { get set }
    var onEndDisplaying: VoidBlock? { get set }
    
    var shouldSpringLoad: ((UISpringLoadedInteractionContext) -> Bool)?  { get set }
    
}

public extension SKCCellRegistrationProtocol {
        
    func dequeue(sectionView: UICollectionView) -> View {
        guard let indexPath = indexPath else {
            assertionFailure()
            return .init()
        }
        let view = sectionView.dequeueReusableCell(withReuseIdentifier: View.identifier, for: indexPath) as! View
        view.config(model)
        viewStyle?(view, model, self)
        return view
    }
    
    func register(sectionView: UICollectionView) {
        if let nib = View.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forCellWithReuseIdentifier: View.identifier)
        }
    }
    
}

public extension SKCCellRegistrationProtocol {
    
    func shouldHighlight(_ block: @escaping BoolInputBlock) -> Self {
        shouldHighlight = wrapper(block)
        return self
    }
    
    func onHighlight(_ block: @escaping VoidInputBlock) -> Self {
        onHighlight = wrapper(block)
        return self
    }
    
    func onUnhighlight(_ block: @escaping VoidInputBlock) -> Self {
        onUnhighlight = wrapper(block)
        return self
    }
    
    func shouldSelect(_ block: @escaping BoolInputBlock) -> Self {
        shouldSelect = wrapper(block)
        return self
    }
    
    func shouldDeselect(_ block: @escaping BoolInputBlock) -> Self {
        shouldDeselect = wrapper(block)
        return self
    }
    
    func onSelected(_ block: @escaping VoidInputBlock) -> Self {
        onSelected = wrapper(block)
        return self
    }
    
    func onDeselected(_ block: @escaping VoidInputBlock) -> Self {
        onDeselected = wrapper(block)
        return self
    }
    
    func canPerformPrimaryAction(_ block: @escaping BoolInputBlock) -> Self {
        canPerformPrimaryAction = wrapper(block)
        return self
    }
    
    func onPerformPrimaryAction(_ block: @escaping VoidInputBlock) -> Self {
        onPerformPrimaryAction = wrapper(block)
        return self
    }
    
    func onWillDisplay(_ block: @escaping VoidInputBlock) -> Self {
        onWillDisplay = wrapper(block)
        return self
    }
    
    func onEndDisplaying(_ block: @escaping VoidInputBlock) -> Self {
        onEndDisplaying = wrapper(block)
        return self
    }
    
    func canFocus(_ block: @escaping BoolInputBlock) -> Self {
        canFocus = wrapper(block)
        return self
    }
    
    func selectionFollowsFocus(_ block: @escaping BoolInputBlock) -> Self {
        selectionFollowsFocus = wrapper(block)
        return self
    }
    
    func canEdit(_ block: @escaping BoolInputBlock) -> Self {
        canEdit = wrapper(block)
        return self
    }
    
    func shouldSpringLoad(_ block: @escaping (_ model: View.Model, _ context: UISpringLoadedInteractionContext) -> Bool) -> Self {
        shouldSpringLoad = { [weak self] context -> Bool in
            guard let self = self else { return false }
            return block(self.model, context)
        }
        return self
    }
    
    func shouldBeginMultipleSelectionInteraction(_ block: @escaping BoolInputBlock) -> Self {
        shouldBeginMultipleSelectionInteraction = wrapper(block)
        return self
    }
    
    func onBeginMultipleSelectionInteraction(_ block: @escaping VoidInputBlock) -> Self {
        onBeginMultipleSelectionInteraction = wrapper(block)
        return self
    }
    
}
