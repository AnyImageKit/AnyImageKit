//
//  EditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol EditorCropToolViewDelegate: AnyObject {
    
    @discardableResult
    func cropToolView(_ toolView: EditorCropToolView, didClickCropOption option: EditorCropOption) -> Bool
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView)
    @discardableResult
    func cropToolViewRotateButtonTapped(_ cropToolView: EditorCropToolView) -> Bool
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
    
    private(set) lazy var rotateButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(options.theme[icon: options.rotationDirection.iconKey], for: .normal)
        view.addTarget(self, action: #selector(rotateButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.registerCell(EditorCropOptionCell.self)
        view.contentInset = UIEdgeInsets(top: 0, left: options.rotationDirection == .turnOff ? 20 : 0, bottom: 0, right: 20)
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
        let view = UIButton(type: .custom)
        view.setImage(options.theme[icon: .xMark], for: .normal)
        view.accessibilityLabel = options.theme[string: .cancel]
        view.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(options.theme[icon: .checkMark], for: .normal)
        view.accessibilityLabel = options.theme[string: .done]
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var resetbutton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(options.theme[string: .reset], for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.setTitleColor(UIColor.lightGray, for: .highlighted)
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
        addSubview(rotateButton)
        addSubview(collectionView)
        addSubview(line)
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(resetbutton)
        
        rotateButton.isHidden = options.rotationDirection == .turnOff
        collectionView.isHidden = options.cropOptions.count <= 1
        
        rotateButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.bottom.equalTo(line.snp.top).offset(-10)
            maker.width.height.equalTo(40)
        }
        collectionView.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(rotateButton)
            if options.rotationDirection == .turnOff {
                maker.left.equalToSuperview()
            } else {
                maker.left.equalTo(rotateButton.snp.right).offset(10)
            }
            maker.right.equalToSuperview()
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
        
        options.theme.buttonConfiguration[.cropRotation]?.configuration(rotateButton)
        options.theme.buttonConfiguration[.cropCancel]?.configuration(cancelButton)
        options.theme.buttonConfiguration[.cropReset]?.configuration(resetbutton)
        options.theme.buttonConfiguration[.cropDone]?.configuration(doneButton)
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
    
    @objc private func rotateButtonTapped(_ sender: UIButton) {
        let result = delegate?.cropToolViewRotateButtonTapped(self) ?? false
        guard result, let cropOption = currentOption else { return }
        if case let .custom(w, h) = cropOption {
            if let idx = options.cropOptions.firstIndex(of: .custom(w: h, h: w)) {
                currentOptionIdx = idx
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension EditorCropToolView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.cropOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(EditorCropOptionCell.self, for: indexPath)
        cell.set(options, option: options.cropOptions[indexPath.row], selectColor: options.theme[color: .primary])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension EditorCropToolView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard currentOption != options.cropOptions[indexPath.row] else { return }
        let nextOption = options.cropOptions[indexPath.row]
        let result = delegate?.cropToolView(self, didClickCropOption: nextOption) ?? false
        if result {
            currentOption = nextOption
        } else {
            collectionView.selectItem(at: IndexPath(row: currentOptionIdx, section: 0), animated: true, scrollPosition: .left)
        }
    }
}
