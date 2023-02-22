//
//  PhotoEditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorCropToolView: UIView {

    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private let itemHeight: CGFloat = 24
    private let minSpacing: CGFloat = 10
    private let maxCount: Int = 6
    private var optionsCount: Int { options.crop.sizes.count }
    
    private let primaryGuide = UILayoutGuide()
    
    private lazy var sectionView = SKCollectionView()
    private lazy var section = EditorCropSection(viewModel: viewModel)
    private lazy var flipButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isHidden = !options.crop.enableFlip
        view.setImage(options.theme[icon: .photoToolCropFlip], for: .normal)
        view.addTarget(self, action: #selector(flipButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .editorFlip]
        return view
    }()
    private lazy var rotationButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(rotationButtonTapped(_:)), for: .touchUpInside)
        switch options.crop.rotationDirection {
        case .turnOff:
            view.isHidden = true
        case .turnLeft:
            view.setImage(options.theme[icon: .photoToolCropTrunLeft], for: .normal)
            view.accessibilityLabel = options.theme[string: .editorTrunLeft]
        case .turnRight:
            view.setImage(options.theme[icon: .photoToolCropTrunRight], for: .normal)
            view.accessibilityLabel = options.theme[string: .editorTrunRight]
        }
        return view
    }()
    private lazy var resetButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(options.theme[icon: .photoToolCropReset], for: .normal)
        view.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .reset]
        return view
    }()
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [flipButton, rotationButton])
        view.distribution = .fillEqually
        view.spacing = 0
        return view
    }()
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [buttonStackView, sectionView, resetButton])
        view.distribution = .fill
        view.spacing = 10
        return view
    }()
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
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
extension PhotoEditorCropToolView {
    
    private func bindViewModel() {
        viewModel.containerSizeSubject.sink { [weak self] size in
            guard let self = self else { return }
            self.updatePlugin()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.section.scrollToSelectedItem(animated: false)
            }
        }.store(in: &cancellable)
        viewModel.traitCollectionSubject.sink { [weak self] traitCollection in
            guard let self = self else { return }
            self.layout()
        }.store(in: &cancellable)
        
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Action
extension PhotoEditorCropToolView {
    
    @objc private func flipButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func rotationButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func resetButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - UI
extension PhotoEditorCropToolView {
    
    private func setupView() {
        sectionView.backgroundColor = .clear
        sectionView.manager.reload(section)
        
        addLayoutGuide(primaryGuide)
        addSubview(stackView)
        
        layout()
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            let buttonCount: CGFloat = 1 + (options.crop.enableFlip ? 1 : 0) + (options.crop.rotationDirection == .turnOff ? 0 : 1)
            primaryGuide.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(50)
                make.height.equalTo(calculateSectionViewLength() + 44 * buttonCount + 10 * 2)
            }
        } else { // iPhone
            primaryGuide.snp.remakeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
            }
        }
    }
    
    private func layout() {
        subviews.forEach { $0.snp.removeConstraints() }
        layoutGuide()
        
        if viewModel.isRegular { // iPad
            stackView.axis = .vertical
            buttonStackView.axis = .vertical
            sectionView.scrollDirection = .vertical
            
            [flipButton, rotationButton, resetButton].forEach {
                $0.snp.remakeConstraints { make in
                    make.width.equalTo(primaryGuide)
                    make.height.equalTo(44)
                }
            }
            stackView.snp.remakeConstraints { make in
                make.edges.equalTo(primaryGuide)
            }
        } else {
            stackView.axis = .horizontal
            buttonStackView.axis = .horizontal
            sectionView.scrollDirection = .horizontal
            
            [flipButton, rotationButton, resetButton].forEach {
                $0.snp.remakeConstraints { make in
                    make.width.equalTo(44)
                    make.height.equalTo(primaryGuide)
                }
            }
            stackView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.leading.trailing.equalToSuperview().inset(15)
            }
        }
        updatePlugin()
    }
    
    private func updatePlugin() {
        if viewModel.isRegular { // iPad
            sectionView.contentInset = .zero
            sectionView.set(pluginModes: [])
        } else {
            let leftButtonCount: CGFloat = (options.crop.enableFlip ? 1 : 0) + (options.crop.rotationDirection == .turnOff ? 0 : 1)
            let buttonCount = max(leftButtonCount, 1) * 2
            let width = calculateSectionViewLength()
            let maxWidth = viewModel.containerSize.width - 15 * 2 - (44 * buttonCount + 10 * (buttonCount - 1))
            if width < maxWidth {
                sectionView.contentInset = UIEdgeInsets(top: 0, left: leftButtonCount < 1 ? 27 : 0, bottom: 0, right: leftButtonCount > 1 ? 27 : 0)
                sectionView.set(pluginModes: [.centerX])
            } else {
                sectionView.contentInset = .zero
                sectionView.set(pluginModes: [])
            }
        }
    }
    
    private func calculateSectionViewLength() -> CGFloat {
        var count = CGFloat(optionsCount)
        if viewModel.isRegular { // iPad
            if optionsCount > maxCount {
                count = CGFloat(maxCount)
                return itemHeight * count + (count - 1) * minSpacing + (minSpacing + itemHeight / 2)
            }
            return itemHeight * count + (count - 1) * minSpacing
        } else {
            let width = options.crop.sizes.map { EditorCropItemCell.preferredSize(limit: .zero, model: .init(title: section.title(of: $0), isSelected: false)).width }.reduce(0, +)
            return width + (count - 1) * minSpacing
        }
    }
}
