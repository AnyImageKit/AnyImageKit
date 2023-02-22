//
//  EditorMosaicSection.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/8.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorMosaicSection: SKCSingleTypeSection<EditorMosaicItemCell> {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var selectedModel: EditorMosaicItemCell.Model? {
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
    private var selectedIndex: Int { (models.firstIndex(where: { $0 == selectedModel })) ?? options.mosaic.defaultMosaicIndex }
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init()
        setup()
    }
}

// MARK: - Public
extension EditorMosaicSection {
    
    func scrollToSelectedItem(animated: Bool = true) {
        if viewModel.isRegular {
            scroll(to: selectedIndex, at: .centeredVertically, animated: animated)
        } else {
            scroll(to: selectedIndex, at: .centeredHorizontally, animated: animated)
        }
    }
}

// MARK: - Private
extension EditorMosaicSection {
    
    private func setup() {
        minimumLineSpacing = 30
        minimumInteritemSpacing = 30
        
        var list: [EditorMosaicItemCell.Model] = []
        for (idx, mosaicStyle) in options.mosaic.style.enumerated() {
            let isSelected = idx == options.mosaic.defaultMosaicIndex
            switch mosaicStyle {
            case .default:
                list.append(.init(isSelected: isSelected, image: options.theme[icon: .photoToolMosaicDefault]?.withRenderingMode(.alwaysTemplate), isDefault: true, tintColor: options.theme[color: .primary]))
            case .custom(let icon, let mosaic):
                list.append(.init(isSelected: isSelected, image: icon ?? mosaic, isDefault: false, tintColor: options.theme[color: .primary]))
            }
            if isSelected {
                selectedModel = list.last
            }
        }
        config(models: list)
        
        setCellStyle { [weak self] context in
            guard let self = self else { return }
            context.view.selectEvent.delegate(on: self) { (self, model) in
                if self.selectedModel == model { return }
                self.selectedModel = model
                self.viewModel.send(action: .mosaicChangeImage(self.selectedIndex))
                self.scrollToSelectedItem()
            }
            self.options.theme.buttonConfiguration[.mosaic(self.options.mosaic.style[context.row])]?.configuration(context.view.button)
        }
    }
}
