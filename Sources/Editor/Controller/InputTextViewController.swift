//
//  InputTextViewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/2.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol InputTextViewControllerDelegate: class {
    
    func inputTextCancelButtonTapped(_ controller: InputTextViewController)
    
}

final class InputTextViewController: UIViewController {
    
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView(image: coverImage)
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(BundleHelper.editorLocalizedString(key: "Cancel"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        view.backgroundColor = manager.photoConfig.tintColor
        view.setTitle(BundleHelper.editorLocalizedString(key: "Done"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var toolView: EditorTextToolView = {
        let view = EditorTextToolView(frame: .zero, config: manager.photoConfig)
        return view
    }()
    
    private weak var delegate: InputTextViewControllerDelegate?
    private let manager: EditorManager
    private let coverImage: UIImage?
    
    init(manager: EditorManager, coverImage: UIImage?, delegate: InputTextViewControllerDelegate) {
        self.delegate = delegate
        self.manager = manager
        self.coverImage = coverImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
    }
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(coverView)
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(toolView)
        
        coverImageView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            if let image = coverImage {
                let height = UIScreen.main.bounds.width * image.size.height / image.size.width
                maker.height.equalTo(height)
            } else {
                maker.height.equalTo(0)
            }
        }
        coverView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(coverImageView)
        }
        cancelButton.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            } else {
                maker.top.equalToSuperview().offset(30)
            }
            maker.left.equalToSuperview().offset(15)
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(cancelButton)
            maker.right.equalToSuperview().offset(-15)
        }
        toolView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview().inset(20)
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            } else {
                maker.bottom.equalToSuperview().offset(-40)
            }
            maker.height.equalTo(30)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Target
extension InputTextViewController {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.inputTextCancelButtonTapped(self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        
    }
}
