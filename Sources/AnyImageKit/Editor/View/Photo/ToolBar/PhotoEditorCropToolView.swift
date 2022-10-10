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

    private var selectedIndex = 0
    private var needLayout = false
    private var layoutWithAnimated = false
    
    private let itemHeight: CGFloat = 24
    private let minSpacing: CGFloat = 10
    private let maxCount: Int = 6
    private var optionsCount: Int { options.crop.sizes.count }
    
    private let primaryGuide = UILayoutGuide()
    
    private lazy var mirrorButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(options.theme[icon: .photoToolCropMirror], for: .normal)
        view.addTarget(self, action: #selector(mirrorButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .editorMirror]
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
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = viewModel.isRegular ? .vertical : .horizontal
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.registerCell(EditorCropItemCell.self)
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
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
//        updateSelectedStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard needLayout else { return }
        needLayout = false
        UIView.animate(withDuration: layoutWithAnimated ? 0.25 : 0) {
            self.collectionView.reloadData()
        } completion: { _ in
            self.setupSectionInset(size: self.viewModel.containerSize)
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
extension PhotoEditorCropToolView {
    
    private func bindViewModel() {
        viewModel.containerSizeSubject.sink { [weak self] size in
            guard let self = self else { return }
            self.needLayout = true
            self.setupSectionInset(size: size)
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
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Action
extension PhotoEditorCropToolView {
    
    @objc private func mirrorButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func rotationButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func resetButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoEditorCropToolView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoEditorCropToolView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.crop.sizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(EditorCropItemCell.self, for: indexPath)
        cell.config(.init(title: title(of: options.crop.sizes[indexPath.row]), isSelected: selectedIndex == indexPath.row))
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoEditorCropToolView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return EditorCropItemCell.preferredSize(limit: collectionView.bounds.size, model: .init(title: title(of: options.crop.sizes[indexPath.row]), isSelected: selectedIndex == indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoEditorCropToolView {
    
    private func setupView() {
        addLayoutGuide(primaryGuide)
        addSubview(mirrorButton)
        addSubview(rotationButton)
        addSubview(collectionView)
        addSubview(resetButton)
        
        layout()
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            primaryGuide.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(50)
                make.height.equalTo(calculateViewLength(count: optionsCount, maxCount: maxCount) + 44 * 3 + 10 * 2)
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
            collectionViewFlowLayout.scrollDirection = .vertical
            mirrorButton.snp.remakeConstraints { make in
                make.top.leading.trailing.equalTo(primaryGuide)
                make.height.equalTo(44)
            }
            rotationButton.snp.remakeConstraints { make in
                make.top.equalTo(mirrorButton.snp.bottom)
                make.leading.trailing.equalTo(primaryGuide)
                make.height.equalTo(44)
            }
            collectionView.snp.remakeConstraints { make in
                make.top.equalTo(rotationButton.snp.bottom).offset(10)
                make.bottom.equalTo(resetButton.snp.top).offset(-10)
                make.centerX.equalTo(primaryGuide)
                make.width.equalTo(primaryGuide)
            }
            resetButton.snp.remakeConstraints { make in
                make.bottom.equalTo(primaryGuide)
                make.centerX.equalTo(primaryGuide)
                make.height.equalTo(44)
            }
        } else {
            collectionViewFlowLayout.scrollDirection = .horizontal
            mirrorButton.snp.remakeConstraints { make in
                make.leading.equalTo(primaryGuide).offset(15)
                make.top.bottom.equalTo(primaryGuide)
                make.width.equalTo(44)
            }
            rotationButton.snp.remakeConstraints { make in
                make.leading.equalTo(mirrorButton.snp.trailing)
                make.top.bottom.equalTo(primaryGuide)
                make.width.equalTo(44)
            }
            collectionView.snp.remakeConstraints { make in
                make.leading.equalTo(rotationButton.snp.trailing).offset(10)
                make.trailing.equalTo(resetButton.snp.leading).offset(-10)
                make.top.bottom.equalTo(primaryGuide)
            }
            resetButton.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.trailing.equalTo(primaryGuide).offset(-15)
                make.width.equalTo(44)
            }
        }
    }
    
    private func setupSectionInset(size: CGSize) {
        if viewModel.isRegular {
            collectionViewFlowLayout.sectionInset = .zero
        } else {
            let width = size.width - 44 * 3 - 10 * 2 - 15 * 2
            let contentSizeWidth = collectionViewFlowLayout.collectionViewContentSize.width - collectionViewFlowLayout.sectionInset.left
            if width > contentSizeWidth {
                let margin = (width - contentSizeWidth) / 2
                collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
            } else {
                collectionViewFlowLayout.sectionInset = .zero
            }
        }
    }
    
    private func title(of size: EditorCropSizeOption) -> String {
        switch size {
        case .free:
            return options.theme[string: .editorFree]
        case .custom(let w, let h):
            return "\(w):\(h)"
        }
    }
    
    private func calculateViewLength(count: Int, maxCount: Int = 0) -> CGFloat {
        var optionsCount = CGFloat(count)
        let maxCount = CGFloat(maxCount)
        if maxCount > 0 {
            optionsCount = optionsCount > maxCount ? maxCount : optionsCount
        }
        return itemHeight * optionsCount + (optionsCount - 1) * minSpacing
    }
}
