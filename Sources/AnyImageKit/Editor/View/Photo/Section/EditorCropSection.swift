//
//  EditorCropSection.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/22.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorCropSection: SKCSingleTypeSection<EditorCropItemCell> {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var selectedModel: EditorCropItemCell.Model? {
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
    private var selectedIndex: Int { (models.firstIndex(where: { $0 == selectedModel })) ?? 0 }
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init()
        setup()
    }
}

// MARK: - Public
extension EditorCropSection {
    
    func title(of size: EditorCropSizeOption) -> String {
        switch size {
        case .free:
            return options.theme[string: .editorFree]
        case .custom(let w, let h):
            return "\(w):\(h)"
        }
    }
    
    func scrollToSelectedItem(animated: Bool = true) {
        if viewModel.isRegular {
            scroll(to: selectedIndex, at: .centeredVertically, animated: animated)
        } else {
            scroll(to: selectedIndex, at: .centeredHorizontally, animated: animated)
        }
    }
}

// MARK: - Private
extension EditorCropSection {
    
    private func setup() {
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        
        var list: [EditorCropItemCell.Model] = []
        for (idx, size) in options.crop.sizes.enumerated() {
            let isSelected = idx == 0
            list.append(.init(title: title(of: size), isSelected: isSelected))
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
                self.viewModel.send(action: .cropUpdateOption(self.options.crop.sizes[self.selectedIndex]))
                self.scrollToSelectedItem()
            }
            self.options.theme.labelConfiguration[.cropOption(self.options.crop.sizes[context.row])]?.configuration(context.view.titleLabel)
        }
    }
}
