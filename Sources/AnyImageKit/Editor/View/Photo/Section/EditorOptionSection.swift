//
//  EditorOptionSection.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/22.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorOptionSection: SKCSingleTypeSection<EditorOptionItemCell> {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var selectedModel: EditorOptionItemCell.Model? {
        willSet {
            newValue?.isSelected = true
        }
        didSet {
            oldValue?.isSelected = false
            UIView.performWithoutAnimation {
                reload()
            }
        }
    }
    private var selectedIndex: Int? { models.firstIndex(where: { $0 == selectedModel }) }
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init()
        setup()
    }
}

// MARK: - Public
extension EditorOptionSection {
    
    func select(at index: Int) {
        guard index < options.toolOptions.count else { return }
        models[index].isSelected = true
        selectedModel = models[index]
    }
    
    func scrollToSelectedItem(animated: Bool = true) {
        guard let selectedIndex else { return }
        if viewModel.isRegular {
            scroll(to: selectedIndex, at: .centeredVertically, animated: animated)
        } else {
            scroll(to: selectedIndex, at: .centeredHorizontally, animated: animated)
        }
    }
}

// MARK: - Private
extension EditorOptionSection {
    
    private func setup() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        var list: [EditorOptionItemCell.Model] = []
        for (_, option) in options.toolOptions.enumerated() {
            let image = options.theme[icon: option.iconKey]?.withRenderingMode(.alwaysTemplate)
            list.append(.init(image: image, isSelected: false, tintColor: options.theme[color: .primary]))
        }
        config(models: list)
        
        setCellStyle { [weak self] context in
            guard let self = self else { return }
            context.view.selectEvent.delegate(on: self) { (self, model) in
                if self.selectedModel == model {
                    self.selectedModel = nil
                    self.viewModel.send(action: .toolOptionChanged(nil))
                } else {
                    self.selectedModel = model
                    let index = self.models.firstIndex(where: { $0 == model }) ?? 0
                    self.viewModel.send(action: .toolOptionChanged(self.options.toolOptions[index]))
                    self.scrollToSelectedItem()
                }
            }
            context.view.button.accessibilityLabel = self.options.theme[string: self.options.toolOptions[context.row].stringKey]
            self.options.theme.buttonConfiguration[.photoOptions(self.options.toolOptions[context.row])]?.configuration(context.view.button)
        }
    }
}
