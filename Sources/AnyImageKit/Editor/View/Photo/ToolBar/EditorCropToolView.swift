//
//  EditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorCropToolViewDelegate: AnyObject {
    
    func cropToolView(_ toolView: EditorCropToolView, didClickCropOption option: EditorCropOption)
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView)
}

final class EditorCropToolView: UIView {
    
    weak var delegate: EditorCropToolViewDelegate?
    
    var currentOptionIdx: Int {
        get {
            if let idx = options.cropOptions.firstIndex(where: { $0 == currentOption }) {
                return idx
            }
            return 0
        } set {
            if newValue < options.cropOptions.count {
                currentOption = options.cropOptions[newValue]
            }
        }
    }
    var currentOption: EditorCropOption? = nil {
        didSet {
            let idx = currentOptionIdx
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .left)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.registerCell(EditorCropOptionCell.self)
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    private lazy var line: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return view
    }()
    private(set) lazy var cancelButton: UIButton = {
        let view = BigButton(moreInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        view.setImage(BundleHelper.image(named: "XMark", module: .editor), for: .normal)
        view.accessibilityLabel = BundleHelper.localizedString(key: "CANCEL", module: .core)
        view.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = BigButton(moreInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        view.setImage(BundleHelper.image(named: "CheckMark", module: .editor), for: .normal)
        view.accessibilityLabel = BundleHelper.localizedString(key: "DONE", module: .core)
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var resetbutton: UIButton = {
        let view = BigButton(moreInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        view.setTitle(BundleHelper.localizedString(key: "RESET", module: .core), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let content = UILayoutGuide()
        addLayoutGuide(content)
        addSubview(collectionView)
        addSubview(line)
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(resetbutton)
        collectionView.isHidden = options.cropOptions.count <= 1
        
        collectionView.snp.makeConstraints { maker in
            maker.bottom.equalTo(line.snp.top).offset(-10)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(40)
        }
        content.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(60)
        }
        line.snp.makeConstraints { maker in
            maker.top.left.right.equalTo(content)
            maker.height.equalTo(0.5)
        }
        cancelButton.snp.makeConstraints { maker in
            maker.left.equalTo(content).offset(20)
            maker.centerY.equalTo(content)
            maker.width.height.equalTo(40)
        }
        doneButton.snp.makeConstraints { maker in
            maker.right.equalTo(content).offset(-20)
            maker.centerY.equalTo(content)
            maker.width.height.equalTo(40)
        }
        resetbutton.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(content)
            maker.centerX.equalTo(content)
            maker.width.equalTo(60)
        }
    }
}

// MARK: - Target
extension EditorCropToolView {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.cropToolViewCancelButtonTapped(self)
    }
    
    @objc private func resetButtonTapped(_ sender: UIButton) {
        if currentOption == .free {
            delegate?.cropToolViewResetButtonTapped(self)
        } else {
            delegate?.cropToolView(self, didClickCropOption: currentOption ?? .free)
        }
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        delegate?.cropToolViewDoneButtonTapped(self)
    }
}

// MARK: - UICollectionViewDataSource
extension EditorCropToolView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.cropOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(EditorCropOptionCell.self, for: indexPath)
        cell.set(option: options.cropOptions[indexPath.row], selectColor: options.tintColor)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension EditorCropToolView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentOption != options.cropOptions[indexPath.row] {
            currentOption = options.cropOptions[indexPath.row]
            delegate?.cropToolView(self, didClickCropOption: currentOption ?? .free)
        }
    }
}

// MARK: - Event
extension EditorCropToolView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        for subView in [cancelButton, doneButton, resetbutton, collectionView] {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
