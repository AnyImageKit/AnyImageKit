//
//  PhotoEditorToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorToolView: UIView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private let topGuide = UILayoutGuide()
    private let bottomGuide = UILayoutGuide()
    
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(options.theme[string: .back], for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .back]
        return view
    }()
    private lazy var doneButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle(options.theme[string: .done], for: .normal)
        view.setTitleColor(options.theme[color: .primary], for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var optionsView: PhotoEditorOptionsView = {
        let view = PhotoEditorOptionsView(viewModel: viewModel)
        return view
    }()
    private lazy var brushView: PhotoEditorBrushToolView = {
        let view = PhotoEditorBrushToolView(viewModel: viewModel)
        view.isHidden = true
        return view
    }()
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
        optionsView.selectFirstItemIfNeeded()
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
extension PhotoEditorToolView {
    
    private func bindViewModel() {
        viewModel.traitCollectionSubject.sink { [weak self] traitCollection in
            self?.layout()
        }.store(in: &cancellable)
        
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .toolOptionChanged(let option):
                self.brushView.isHidden = option != .brush
            case .brushBeginDraw:
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 0.0
                }
            case .brushFinishDraw:
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1.0
                }
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Target
extension PhotoEditorToolView {
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        viewModel.send(action: .back)
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        viewModel.send(action: .done)
    }
}

// MARK: - UI
extension PhotoEditorToolView {
    
    private func setupView() {
        addLayoutGuide(topGuide)
        addLayoutGuide(bottomGuide)
        addSubview(backButton)
        addSubview(doneButton)
        addSubview(optionsView)
        addSubview(brushView)
        
        layout()
    }
    
    private func layoutGuide() {
        layoutGuides.forEach { $0.snp.removeConstraints() }
        topGuide.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        bottomGuide.snp.remakeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func layout() {
        let marginOffset: CGFloat = viewModel.isRegular ? 30 : 20
        subviews.forEach { $0.snp.removeConstraints() }
        layoutGuide()
        
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(marginOffset)
            make.centerY.equalTo(topGuide)
        }
        
        if viewModel.isRegular { // iPad
            doneButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().offset(-marginOffset)
                make.centerY.equalTo(topGuide)
            }
            optionsView.snp.remakeConstraints { make in
                make.top.equalTo(topGuide.snp.bottom)
                make.bottom.equalTo(bottomGuide.snp.top)
                make.leading.equalToSuperview().offset(marginOffset)
                make.width.equalTo(50)
            }
            brushView.snp.remakeConstraints { make in
                make.top.equalTo(topGuide.snp.bottom)
                make.bottom.equalTo(bottomGuide.snp.top)
                make.trailing.equalToSuperview().offset(-30)
                make.width.equalTo(100)
            }
        } else { // iPhone
            doneButton.snp.remakeConstraints { make in
                make.trailing.equalTo(bottomGuide).offset(-marginOffset)
                make.centerY.equalTo(bottomGuide)
            }
            optionsView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(bottomGuide)
                make.leading.equalTo(bottomGuide).offset(marginOffset)
                make.trailing.equalTo(doneButton.snp.leading).offset(-marginOffset)
            }
            brushView.snp.remakeConstraints { make in
                make.bottom.equalTo(bottomGuide.snp.top)
                make.leading.trailing.equalTo(bottomGuide)
                make.height.equalTo(100)
            }
        }
    }
}
