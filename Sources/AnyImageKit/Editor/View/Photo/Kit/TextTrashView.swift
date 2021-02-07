//
//  TextTrashView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/28.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class TextTrashView: UIView {

    enum State {
        case idle
        case remove
    }
    
    var state: State = .idle {
        didSet {
            set(state: state)
        }
    }
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "Trash", module: .editor)
        return view
    }()
    private(set) lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "DRAG_HERE_TO_REMOVE", module: .editor)
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = Palette.black.withAlphaComponent(0.8)
        addSubview(imageView)
        addSubview(label)
        
        imageView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(15)
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(25)
        }
        label.snp.makeConstraints { maker in
            maker.top.equalTo(imageView.snp.bottom).offset(15)
            maker.left.right.equalToSuperview().inset(10)
        }
    }
    
    private func set(state: State) {
        switch state {
        case .idle:
            backgroundColor = Palette.black.withAlphaComponent(0.9)
            label.text = BundleHelper.localizedString(key: "DRAG_HERE_TO_REMOVE", module: .editor)
        case .remove:
            backgroundColor = Palette.red.withAlphaComponent(0.9)
            label.text = BundleHelper.localizedString(key: "RELEASE_TO_REMOVE", module: .editor)
        }
    }
}
