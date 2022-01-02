//
//  TextTrashView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/28.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
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
        view.image = options.theme[icon: .trash]
        return view
    }()
    private(set) lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = options.theme[string: .editorDragHereToRemove]
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    
    init(options: EditorPhotoOptionsInfo, frame: CGRect) {
        self.options = options
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
            label.text = options.theme[string: .editorDragHereToRemove]
        case .remove:
            backgroundColor = Palette.red.withAlphaComponent(0.9)
            label.text = options.theme[string: .editorReleaseToRemove]
        }
        
        options.theme.labelConfiguration[.trash]?.configuration(label)
    }
}
