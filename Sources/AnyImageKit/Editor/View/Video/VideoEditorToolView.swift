//
//  VideoEditorToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol VideoEditorToolViewDelegate: AnyObject {
    
    func videoEditorTool(_ tool: VideoEditorToolView, optionDidChange option: EditorVideoToolOption?)
}

final class VideoEditorToolView: UIView {

    public weak var delegate: VideoEditorToolViewDelegate?
    private(set) var currentOption: EditorVideoToolOption?
    
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.backgroundColor = options.theme[color: .primary]
        view.setTitle(options.theme[string: .done], for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        return view
    }()
    private var buttons: [UIButton] = []
    private let spacing: CGFloat = 25
    
    private let options: EditorVideoOptionsInfo
    
    init(frame: CGRect, options: EditorVideoOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(doneButton)
        doneButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.right.equalToSuperview()
        }
        
        
        for (idx, option) in options.toolOptions.enumerated() {
            let button = createButton(tag: idx, option: option)
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.equalToSuperview()
        }
        buttons.forEach {
            $0.snp.makeConstraints { maker in
                maker.width.height.equalTo(stackView.snp.height)
            }
            options.theme.buttonConfiguration[.videoOptions(options.toolOptions[$0.tag])]?.configuration($0)
        }
        
        options.theme.buttonConfiguration[.done]?.configuration(doneButton)
    }
    
    private func createButton(tag: Int, option: EditorVideoToolOption) -> UIButton {
        let button = UIButton(type: .custom)
        let image = options.theme[icon: option.iconKey]?.withRenderingMode(.alwaysTemplate)
        button.tag = tag
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        button.accessibilityLabel = options.theme[string: option.stringKey]
        return button
    }
    
    private func selectButton(_ button: UIButton) {
        currentOption = options.toolOptions[button.tag]
        for btn in buttons {
            let isSelected = btn == button
            btn.isSelected = isSelected
            btn.imageView?.tintColor = isSelected ? options.theme[color: .primary] : .white
        }
    }
}

// MARK: - Public
extension VideoEditorToolView {
    
    func selectOption(_ option: EditorVideoToolOption) -> Bool {
        guard let idx = options.toolOptions.firstIndex(of: option) else { return false }
        selectButton(buttons[idx])
        return true
    }
    
    func unselectButtons() {
        self.currentOption = nil
        for button in buttons {
            button.isSelected = false
            button.imageView?.tintColor = .white
        }
    }
}

// MARK: - Target
extension VideoEditorToolView {
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        if let current = currentOption, options.toolOptions[sender.tag] == current {
            unselectButtons()
        } else {
            selectButton(sender)
        }
        delegate?.videoEditorTool(self, optionDidChange: currentOption)
    }
}
