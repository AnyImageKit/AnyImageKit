//
//  PhotoEditorOptionsView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorOptionsView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private let itemWidth: CGFloat = 44
    private let minSpacing: CGFloat = 0
    
    private let contentView = UIView(frame: .zero)
    
    private lazy var sectionView = SKCollectionView()
    private lazy var section = EditorOptionSection(viewModel: viewModel)
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlugin()
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
            self.updatePlugin()
        }.store(in: &cancellable)
        
        viewModel.traitCollectionSubject.sink { [weak self] traitCollection in
            guard let self = self else { return }
            self.layout()
        }.store(in: &cancellable)
    }
}

// MARK: - Public
extension PhotoEditorOptionsView {
    
    public func selectFirstItemIfNeeded() {
        if viewModel.isRegular {
            section.select(at: 0)
            viewModel.send(action: .toolOptionChanged(options.toolOptions[0]))
        }
    }
}

// MARK: - UI
extension PhotoEditorOptionsView {
    
    private func setupView() {
        sectionView.backgroundColor = .clear
        sectionView.manager.reload(section)
        
        addSubview(contentView)
        contentView.addSubview(sectionView)
        layout()
    }
    
    private func layout() {
        subviews.forEach { $0.snp.removeConstraints() }
        
        if viewModel.isRegular { // iPad
            contentView.layer.cornerRadius = 25
            contentView.backgroundColor = UIColor.color(hex: 0x282828).withAlphaComponent(0.8)
            sectionView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            sectionView.scrollDirection = .vertical
            
            contentView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(calculateSectionViewLength() + 24)
            }
            sectionView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else { // iPhone
            contentView.backgroundColor = .clear
            sectionView.contentInset = .zero
            sectionView.scrollDirection = .horizontal
            
            contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            sectionView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
                make.centerY.equalToSuperview()
            }
        }
        updatePlugin()
    }
    
    private func updatePlugin() {
        if viewModel.isRegular { // iPad
            sectionView.set(pluginModes: [])
        } else {
            let width = calculateSectionViewLength()
            let maxWidth = bounds.width
            if width < maxWidth {
                sectionView.set(pluginModes: [.centerX])
            } else {
                sectionView.set(pluginModes: [])
            }
        }
    }
    
    private func calculateSectionViewLength() -> CGFloat {
        let count = CGFloat(options.toolOptions.count)
        return itemWidth * count + (count - 1) * minSpacing
    }
    
}
