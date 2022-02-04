//
//  PhotoEditorFilterToolView.swift
//  AnyImageKit
//
//  Created by Ray on 2022/2/4.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorFilterToolView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var selectedIndex = options.mosaic.defaultMosaicIndex
    private var needLayout = false
    private var layoutWithAnimated = false
    
    private let iconWidth: CGFloat = 24
    private let itemWidth: CGFloat = 50
    private let minSpacing: CGFloat = 2
//    private let maxCount: Int = 4
    private var optionsCount: Int { options.mosaic.style.count }
    
    private let primaryGuide = UILayoutGuide()
    private let secondaryGuide = UILayoutGuide()
    
    private lazy var collectionView: ArcCollectionView = {
        let view = ArcCollectionView(items: createItems(), size: .init(width: itemWidth, height: itemWidth), spacing: minSpacing, topMargin: 12, bottomMargin: 3)
        view.updateLayout(isRegular: viewModel.isRegular)
        return view
    }()
    private lazy var progressCollectionView: ArcCollectionView = {
        let view = ArcCollectionView(items: createProgressItems(), size: .init(width: 1, height: 10), spacing: 9, topMargin: 20, bottomMargin: 5)
        view.updateLayout(isRegular: viewModel.isRegular)
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
        collectionView.updateLayout(isRegular: viewModel.isRegular)
        progressCollectionView.updateLayout(isRegular: viewModel.isRegular)
        
        guard needLayout else { return }
        needLayout = false
        UIView.animate(withDuration: layoutWithAnimated ? 0.25 : 0) {
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
extension PhotoEditorFilterToolView {
    
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
//            case .mosaicFinishDraw:
//                self.undoButton.isEnabled = self.viewModel.stack.edit.mosaicCanUndo
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

extension PhotoEditorFilterToolView {
    
    private func setupView() {
        addLayoutGuide(primaryGuide)
        addLayoutGuide(secondaryGuide)
        
        addSubview(collectionView)
        addSubview(progressCollectionView)
        
        setupCenterView()
        layout()
    }
    
    private func setupCenterView() {
        let primaryCenterView = UIView(frame: .zero)
        primaryCenterView.isUserInteractionEnabled = false
        primaryCenterView.layer.borderWidth = 2.5
        primaryCenterView.layer.cornerRadius = 6
        primaryCenterView.layer.borderColor = UIColor.white.cgColor
        collectionView.setCenterView(primaryCenterView, size: CGSize(width: itemWidth+4, height: itemWidth+4))
        
//        let secondaryCenterView = UIView(frame: .zero)
//        secondaryCenterView.isUserInteractionEnabled = false
//        secondaryCenterView.backgroundColor = .white
//        progressCollectionView.setCenterView(secondaryCenterView, size: CGSize(width: 1, height: 30))
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            primaryGuide.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(65)
                make.height.equalToSuperview()
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.trailing.equalToSuperview()
                make.width.equalTo(35)
            }
        } else { // iPhone
            primaryGuide.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(65)
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(35)
            }
        }
    }
    
    private func layout() {
        subviews.forEach { $0.snp.removeConstraints() }
        layoutGuide()
        
        if viewModel.isRegular { // iPad
            collectionView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide).inset(30)
                make.leading.trailing.equalTo(primaryGuide)
            }
            progressCollectionView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(collectionView)
                make.leading.trailing.equalTo(secondaryGuide)
            }
        } else { // iPhone
            collectionView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.leading.trailing.equalTo(primaryGuide).inset(30)
            }
            progressCollectionView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(secondaryGuide)
                make.leading.trailing.equalTo(collectionView)
            }
        }
    }
    
    private func createItems() -> [UIView] {
        return Array(repeating: 0, count: 30).enumerated().map { (idx, style) -> UIView in
//            return createMosaicButton(idx: idx, style: style)
            let view = UIImageView(image: viewModel.image)
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            return view
        }
    }
    
    private func createProgressItems() -> [UIView] {
        return Array(repeating: 0, count: 40).enumerated().map { (idx, style) -> UIView in
            let highlight = idx % 10 == 0
            let view = UIView(frame: .zero)
            view.backgroundColor = highlight ? .white : .color(hex: 0xB5B5B5)
            return view
        }
    }
    
//    private func createMosaicButton(idx: Int, style: EditorMosaicStyleOption) -> UIButton {
//    }
    
}
