//
//  PhotoEditorMosaicToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/3.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorMosaicToolView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var selectedIndex = options.mosaic.defaultMosaicIndex
    private var needLayout = false
    private var layoutWithAnimated = false
    
    private let iconWidth: CGFloat = 24
    private let itemWidth: CGFloat = 34
    private let minSpacing: CGFloat = 50
    private let maxCountMinSpacing: CGFloat = 20
    private let maxCount: Int = 4
    private var optionsCount: Int { options.mosaic.style.count }
    
    private let primaryGuide = UILayoutGuide()
    private let secondaryGuide = UILayoutGuide()
    
    private lazy var collectionView: ToolCollectionView = {
        let view = ToolCollectionView(items: createItems(), size: itemWidth, spacing: calculateSpacing())
        return view
    }()
    private lazy var undoButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(options.theme[icon: .photoToolUndo], for: .normal)
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .undo]
        return view
    }()
    private lazy var slider: UISlider = {
        let view = UISlider(frame: .zero)
        view.isHidden = !options.mosaic.lineWidth.isDynamic
        view.alpha = 0.4
        view.minimumTrackTintColor = .white
        view.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        view.value = options.mosaic.lineWidth.percent(of: options.mosaic.lineWidth.width)
        view.layer.applySketchShadow(color: .black.withAlphaComponent(0.4), alpha: 0.5, x: 0, y: 0, blur: 4, spread: 0)
        view.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        view.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return view
    }()
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
        updateSelectedStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard needLayout else { return }
        needLayout = false
        UIView.animate(withDuration: layoutWithAnimated ? 0.25 : 0) {
            self.collectionView.spacing = self.calculateSpacing()
            self.collectionView.collectionView.reloadData()
        }
        layoutWithAnimated = false
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
extension PhotoEditorMosaicToolView {
    
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
        
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .mosaicFinishDraw:
                self.undoButton.isEnabled = self.viewModel.stack.edit.mosaicCanUndo
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Target
extension PhotoEditorMosaicToolView {
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        viewModel.send(action: .mosaicUndo)
        sender.isEnabled = viewModel.stack.edit.mosaicCanUndo
    }
    
    @objc private func mosaicButtonTapped(_ sender: UIButton) {
        if selectedIndex != sender.tag {
            selectedIndex = sender.tag
            updateSelectedStyle()
        }
        viewModel.send(action: .mosaicChangeImage(selectedIndex))
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        viewModel.send(action: .mosaicChangeLineWidth(options.mosaic.lineWidth.width(of: sender.value)))
    }
    
    @objc private func sliderTouchDown(_ sender: UISlider) {
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 1.0
        }
    }
    
    @objc private func sliderTouchUp(_ sender: UISlider) {
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 0.4
        }
    }
}

// MARK: - UI
extension PhotoEditorMosaicToolView {
    
    private func setupView() {
        addLayoutGuide(primaryGuide)
        addLayoutGuide(secondaryGuide)
        
        addSubview(collectionView)
        addSubview(undoButton)
        addSubview(slider)
        
        layout()
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            primaryGuide.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(50)
                make.height.equalTo(calculateViewLength(count: maxCount, maxCount: maxCount) + 10 + 44)
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.leading.equalToSuperview()
                make.width.equalTo(primaryGuide)
            }
        } else { // iPhone
            primaryGuide.snp.remakeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(primaryGuide)
            }
        }
    }
    
    private func layout() {
        subviews.forEach { $0.snp.removeConstraints() }
        layoutGuide()
        
        if viewModel.isRegular { // iPad
            collectionView.snp.remakeConstraints { make in
                make.top.equalTo(primaryGuide)
                make.bottom.equalTo(undoButton.snp.top).offset(-10)
                make.centerX.equalTo(primaryGuide)
                make.width.equalTo(itemWidth)
            }
            undoButton.snp.remakeConstraints { make in
                make.bottom.equalTo(primaryGuide)
                make.centerX.equalTo(primaryGuide)
                make.width.height.equalTo(44)
            }
            slider.transform = .identity.rotated(by: -(CGFloat.pi/2))
            slider.snp.remakeConstraints { make in
                make.width.equalTo(secondaryGuide.snp.height)
                make.center.equalTo(secondaryGuide)
            }
        } else { // iPhone
            collectionView.snp.remakeConstraints { make in
                make.leading.equalTo(primaryGuide).offset(15)
                make.trailing.equalTo(undoButton.snp.leading).offset(-20)
                make.centerY.equalTo(primaryGuide)
                make.height.height.equalTo(itemWidth)
            }
            undoButton.snp.remakeConstraints { make in
                make.trailing.equalTo(primaryGuide).offset(-15)
                make.centerY.equalTo(primaryGuide)
                make.width.height.equalTo(44)
            }
            slider.transform = .identity
            slider.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(secondaryGuide).inset(15)
                make.centerY.equalTo(secondaryGuide)
            }
        }
        
        let count = options.mosaic.style.count
        let value = calculateViewLength(count: count, maxCount: maxCount)
        collectionView.layout(style: count >= maxCount ? .full : .center(value: value, offset: 30), isRegular: viewModel.isRegular)
    }
    
    private func updateSelectedStyle() {
        let style = options.mosaic.style[selectedIndex]
        let mosaicButtons = collectionView.items.map { $0 as! UIButton }
        switch style {
        case .default:
            for button in mosaicButtons {
                button.tintColor = options.theme[color: .primary]
                button.imageView?.layer.borderWidth = 0
            }
        default:
            for (idx, button) in mosaicButtons.enumerated() {
                button.tintColor = .white
                button.imageView?.layer.borderWidth = idx == selectedIndex ? 2 : 0
            }
        }
    }
    
    private func createItems() -> [UIView] {
        return options.mosaic.style.enumerated().map { (idx, style) -> UIView in
            return createMosaicButton(idx: idx, style: style)
        }
    }
    
    private func createMosaicButton(idx: Int, style: EditorMosaicStyleOption) -> UIButton {
        let image: UIImage?
        switch style {
        case .default:
            image = options.theme[icon: .photoToolMosaicDefault]?.withRenderingMode(.alwaysTemplate)
        case .custom(let icon, let mosaic):
            image = icon ?? mosaic
        }
        let inset = (itemWidth - iconWidth) / 2
        let button = UIButton(type: .custom)
        button.tag = idx
        button.tintColor = .white
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.imageView?.layer.cornerRadius = style == .default ? 0 : 2
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(mosaicButtonTapped(_:)), for: .touchUpInside)
        options.theme.buttonConfiguration[.mosaic(style)]?.configuration(button)
        return button
    }
    
    private func calculateViewLength(count: Int, maxCount: Int = 0) -> CGFloat {
        var optionsCount = CGFloat(count)
        let maxCount = CGFloat(maxCount)
        if maxCount > 0 {
            optionsCount = optionsCount > maxCount ? maxCount : optionsCount
        }
        
        if optionsCount >= maxCount {
            return itemWidth * optionsCount + (optionsCount - 1) * maxCountMinSpacing
        } else {
            return itemWidth * optionsCount + (optionsCount - 1) * minSpacing
        }
    }
    
    private func calculateSpacing() -> CGFloat {
        if optionsCount < maxCount {
            return minSpacing
        }
        
        var spacing: CGFloat = maxCountMinSpacing
        let count = CGFloat(optionsCount)
        
        let maxSize: CGFloat
        if viewModel.isRegular { // iPad
            maxSize = primaryGuide.layoutFrame.height - 15 - 44
        } else { // iPhone
            maxSize = primaryGuide.layoutFrame.width - 15 - 20 - 44 - 15
        }
        
        if primaryGuide.layoutFrame == .zero {
            needLayout = true
        }

        if calculateViewLength(count: optionsCount) < maxSize {
            spacing = (maxSize - itemWidth * count) / (count - 1)
        }
        return spacing
    }
}
