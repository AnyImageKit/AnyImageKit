//
//  PhotoEditorBrushToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorBrushToolView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
        
    private let itemWidth: CGFloat = 34
    private let minSpacing: CGFloat = 10
    private let maxCount: Int = 7
    private var optionsCount: Int { options.brush.colors.count }
    
    private let primaryGuide = UILayoutGuide()
    private let secondaryGuide = UILayoutGuide()
    
    private lazy var sectionView = SKCollectionView()
    private lazy var section = EditorBrushSection(viewModel: viewModel)
    
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
        view.isHidden = !options.brush.lineWidth.isDynamic
        view.alpha = 0.4
        view.minimumTrackTintColor = .white
        view.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        view.value = options.brush.lineWidth.percent(of: options.brush.lineWidth.width)
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
extension PhotoEditorBrushToolView {
    
    private func bindViewModel() {
        viewModel.containerSizeSubject.sink { [weak self] _ in
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
            case .brushFinishDraw:
                self.undoButton.isEnabled = self.viewModel.stack.edit.brushCanUndo
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Target
extension PhotoEditorBrushToolView {
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        viewModel.send(action: .brushUndo)
        sender.isEnabled = viewModel.stack.edit.brushCanUndo
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        viewModel.send(action: .brushChangeLineWidth(options.brush.lineWidth.width(of: sender.value)))
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
extension PhotoEditorBrushToolView {
    
    private func setupView() {
        sectionView.backgroundColor = .clear
        sectionView.manager.reload(section)
        addLayoutGuide(primaryGuide)
        addLayoutGuide(secondaryGuide)
        
        addSubview(sectionView)
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
                make.height.equalTo(calculateSectionViewLength() + 10 + 44)
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
            sectionView.scrollDirection = .vertical
            sectionView.snp.remakeConstraints { make in
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
            sectionView.scrollDirection = .horizontal
            sectionView.snp.remakeConstraints { make in
                make.leading.equalTo(primaryGuide).offset(15)
                make.trailing.equalTo(undoButton.snp.leading).offset(-15)
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
        updatePlugin()
    }
    
    private func updatePlugin() {
        if viewModel.isRegular { // iPad
            sectionView.contentInset = .zero
            sectionView.set(pluginModes: [])
        } else {
            let width = calculateSectionViewLength()
            let maxWidth = viewModel.containerSize.width - 15 * 2 - (44 + 10) * 2
            if width < maxWidth {
                sectionView.contentInset = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 0)
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
                return itemWidth * count + (count - 1) * minSpacing + (minSpacing + itemWidth / 2)
            }
            return itemWidth * count + (count - 1) * minSpacing
        } else {
            return itemWidth * count + (count - 1) * minSpacing
        }
    }
}
