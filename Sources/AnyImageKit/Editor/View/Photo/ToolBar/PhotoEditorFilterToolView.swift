//
//  PhotoEditorFilterToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/4.
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
    
    private let itemWidth: CGFloat = 55
    private var optionsCount: Int { options.mosaic.style.count }
    
    private let primaryGuide = UILayoutGuide()
    private let secondaryGuide = UILayoutGuide()
    
    private lazy var collectionView: FilterCollectionView = {
        let option = FilterCollectionView.ArcOption(size: .init(width: itemWidth, height: itemWidth),
                                                    spacing: 2,
                                                    topMargin: 15,
                                                    bottomMargin: 5,
                                                    dotIndex: 0,
                                                    selectedIndex: .index(0))
        let view = FilterCollectionView(option: option, images: createItems())
        view.updateLayout(isRegular: viewModel.isRegular)
        return view
    }()
    private lazy var progressCollectionView: SliderCollectionView = {
        let option = SliderCollectionView.ArcOption(size: .init(width: 1, height: 10),
                                                    spacing: 9,
                                                    topMargin: 20,
                                                    bottomMargin: 15,
                                                    dotIndex: 0,
                                                    selectedIndex: .present(0))
        let view = SliderCollectionView(option: option, count: 41)
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
        collectionView.setCenterView(primaryCenterView, size: CGSize(width: itemWidth+4, height: itemWidth+4), topMargin: collectionView.topMargin-2.5)
        
        let secondaryCenterView = UIView(frame: .zero)
        secondaryCenterView.isUserInteractionEnabled = false
        secondaryCenterView.backgroundColor = .white
        progressCollectionView.setCenterView(secondaryCenterView, size: CGSize(width: 1, height: 25), topMargin: 5)
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            primaryGuide.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(75)
                make.height.equalToSuperview()
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.top.bottom.equalTo(primaryGuide)
                make.trailing.equalToSuperview()
                make.width.equalTo(45)
            }
        } else { // iPhone
            primaryGuide.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(75)
            }
            secondaryGuide.snp.remakeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(45)
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
    
    private func createItems() -> [UIImage] {
        return Array(repeating: 0, count: 30).enumerated().map { (idx, style) -> UIImage in
//            return createMosaicButton(idx: idx, style: style)
//            let view = UIImageView(image: viewModel.image)
//            view.contentMode = .scaleAspectFill
//            view.clipsToBounds = true
//            return view
            return viewModel.image
        }
    }
    
    private func createProgressItems() -> [UIView] {
        return Array(repeating: 0, count: 41).enumerated().map { (idx, style) -> UIView in
            let highlight = idx % 10 == 0
            let view = UIView(frame: .zero)
            view.backgroundColor = highlight ? .white : .color(hex: 0xB5B5B5)
            return view
        }
    }
    
//    private func createMosaicButton(idx: Int, style: EditorMosaicStyleOption) -> UIButton {
//    }
    
}
