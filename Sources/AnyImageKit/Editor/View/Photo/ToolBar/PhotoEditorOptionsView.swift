//
//  PhotoEditorOptionsView.swift
//  AnyImageKit
//
//  Created by Ray on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorOptionsView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private(set) var currentOption: EditorPhotoToolOption?
    private var needLayout = false
    private var layoutWithAnimated = false
    
    private let itemWidth: CGFloat = 44
    private let minSpacing: CGFloat = 10
    
    private let contentView = UIView(frame: .zero)
    
    private lazy var collectionView: ToolCollectionView = {
        let view = ToolCollectionView(items: createItems(), size: itemWidth, spacing: calculateSpacing())
        return view
    }()
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard needLayout else { return }
        needLayout = false
        if layoutWithAnimated {
            layoutWithAnimated = false
            UIView.animate(withDuration: 0.25) {
                self.collectionView.spacing = self.calculateSpacing()
            } completion: { _ in
                self.collectionView.collectionView.reloadData()
            }
        } else {
            self.collectionView.spacing = self.calculateSpacing()
            self.collectionView.collectionView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        for subView in subviews {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}

// MARK: - Observer
extension PhotoEditorOptionsView {
    
    private func bindViewModel() {
        viewModel.containerSizeSubject.sink { [weak self] _ in
            guard let self = self else { return }
            self.needLayout = true
        }.store(in: &cancellable)
        viewModel.traitCollectionSubject.sink { [weak self] traitCollection in
            guard let self = self else { return }
            self.layout()
            self.needLayout = true
            self.layoutWithAnimated = true
        }.store(in: &cancellable)
    }
}

// MARK: - Target
extension PhotoEditorOptionsView {
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        let nextOption: EditorPhotoToolOption?
        if let current = currentOption, options.toolOptions[sender.tag] == current {
            nextOption = nil
        } else {
            nextOption = options.toolOptions[sender.tag]
        }
        
        viewModel.send(action: .toolOptionChanged(nextOption))
        if nextOption == nil {
            unselectButtons()
        } else {
            selectButton(sender)
        }
    }
    
    private func selectButton(_ button: UIButton) {
        currentOption = options.toolOptions[button.tag]
        for item in collectionView.items as! [UIButton] {
            let isSelected = item == button
            item.isSelected = isSelected
            item.imageView?.tintColor = isSelected ? options.theme[color: .primary] : .white
        }
    }
    
    private func unselectButtons() {
        currentOption = nil
        for item in collectionView.items as! [UIButton] {
            item.isSelected = false
            item.imageView?.tintColor = .white
        }
    }
}

// MARK: - Public
extension PhotoEditorOptionsView {
    
    public func selectFirstItemIfNeeded() {
        guard let firstItem = collectionView.items.first as? UIButton else { return }
        if viewModel.isRegular {
            optionButtonTapped(firstItem)
        }
    }
}

// MARK: - UI
extension PhotoEditorOptionsView {
    
    private func setupView() {
        addSubview(contentView)
        contentView.addSubview(collectionView)
        layout()
    }
    
    private func layout() {
        subviews.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            contentView.layer.cornerRadius = 25
            contentView.backgroundColor = UIColor.color(hex: 0x282828).withAlphaComponent(0.8)
            collectionView.collectionView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            
            contentView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(calculateCollectionLength() + 24)
            }
            collectionView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(44)
            }
        } else { // iPhone
            contentView.backgroundColor = .clear
            collectionView.collectionView.contentInset = .zero
            
            contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            collectionView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    private func createItems() -> [UIButton] {
        return options.toolOptions.enumerated().map { (idx, option) in
            let button = UIButton(type: .custom)
            let image = options.theme[icon: option.iconKey]?.withRenderingMode(.alwaysTemplate)
            button.tag = idx
            button.setImage(image, for: .normal)
            button.imageView?.tintColor = .white
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.accessibilityLabel = options.theme[string: option.stringKey]
            return button
        }
    }
    
    private func calculateCollectionLength() -> CGFloat {
        let optionsCount = CGFloat(options.toolOptions.count)
        return itemWidth * optionsCount + (optionsCount - 1) * minSpacing
    }
    
    private func calculateSpacing() -> CGFloat {
        var spacing: CGFloat = minSpacing
        let optionsCount = CGFloat(options.toolOptions.count)
        let maxSize = contentView.frame.height > contentView.frame.width ? contentView.frame.height - 24 : contentView.frame.width
        if calculateCollectionLength() < maxSize {
            spacing = (maxSize - itemWidth * optionsCount) / (optionsCount - 1)
        }
        return spacing
    }
}
