//
//  EditorBrushSection.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/7.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorBrushSection: SKCSectionProtocol {
    
    private enum CellType {
        case normal(EditorBrushItemModel)
        case colorWell(EditorBrushItemModel)
        
        var model: EditorBrushItemModel {
            switch self {
            case .normal(let model): return model
            case .colorWell(let model): return model
            }
        }
    }
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cellTypes: [CellType] = []
    private var selectedModel: EditorBrushItemModel? {
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
    private var selectedIndex: Int { (cellTypes.firstIndex(where: { $0.model == selectedModel })) ?? options.brush.defaultColorIndex }
    
    var sectionInjection: SKCSectionInjection?
    var itemCount: Int { options.brush.colors.count }
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        setup()
    }
    
}

// MARK: - Public
extension EditorBrushSection {
    
    func scrollToSelectedItem(animated: Bool = true) {
        if viewModel.isRegular {
            scroll(to: selectedIndex, at: .centeredVertically, animated: animated)
        } else {
            scroll(to: selectedIndex, at: .centeredHorizontally, animated: animated)
        }
    }
}

// MARK: - Private
extension EditorBrushSection {
    
    private func setup() {
        for (idx, colorOption) in options.brush.colors.enumerated() {
            let isSelected = idx == options.brush.defaultColorIndex
            switch colorOption {
            case .custom(let color):
                cellTypes.append(.normal(.init(isSelected: isSelected, color: color)))
            case .colorWell(let color):
                cellTypes.append(.colorWell(.init(isSelected: isSelected, color: color)))
            }
            if isSelected {
                selectedModel = cellTypes.last?.model
            }
        }
    }
}

// MARK: - Config
extension EditorBrushSection {
    
    func config(sectionView: UICollectionView) {
        register(EditorBrushItemCell.self)
        if #available(iOS 14.0, *) {
            register(EditorBrushItemColorWellCell.self)
        }
    }
    
    func itemSize(at row: Int) -> CGSize {
        return CGSize(width: 34, height: 34)
    }
    
    func item(at row: Int) -> UICollectionViewCell {
        let model = cellTypes[row].model
        if case .colorWell = cellTypes[row], #available(iOS 14.0, *) {
            let cell = dequeue(at: row) as EditorBrushItemColorWellCell
            cell.config(model)
            cell.selectEvent.delegate(on: self) { (self, model) in
                if self.selectedModel == model { return }
                self.selectedModel = model
                self.viewModel.send(action: .brushChangeColor(model.color))
                self.scrollToSelectedItem()
            }
            cell.updateEvent.delegate(on: self) { (self, model) in
                UIView.performWithoutAnimation {
                    self.reload()
                }
                self.viewModel.send(action: .brushChangeColor(model.color))
            }
            return cell
        } else {
            let cell = dequeue(at: row) as EditorBrushItemCell
            cell.config(model)
            cell.selectEvent.delegate(on: self) { (self, model) in
                if self.selectedModel == model { return }
                self.selectedModel = model
                self.viewModel.send(action: .brushChangeColor(model.color))
                self.scrollToSelectedItem()
            }
            options.theme.buttonConfiguration[.brush(options.brush.colors[row])]?.configuration(cell.colorButton)
            return cell
        }
    }
}

// MARK: - Model
final class EditorBrushItemModel: Equatable {
    let id = UUID().uuidString
    var isSelected: Bool
    var color: UIColor
    
    init(isSelected: Bool, color: UIColor) {
        self.isSelected = isSelected
        self.color = color
    }
    
    static func == (lhs: EditorBrushItemModel, rhs: EditorBrushItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
