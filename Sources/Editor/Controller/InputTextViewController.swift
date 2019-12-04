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
    private lazy var textCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 32)
        return view
    }()
    /// 仅用于计算TextView最后一行的文本
    private lazy var calculatelabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.font = UIFont.systemFont(ofSize: 32)
        return view
    }()
    
    private let lineHeight: CGFloat = 36
    
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
    
    deinit {
        removeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
        addNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textView.becomeFirstResponder()
    }
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(coverView)
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(toolView)
        view.addSubview(textCoverView)
        textCoverView.addSubview(textView)
        view.addSubview(calculatelabel)
        
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
        textCoverView.snp.makeConstraints { (maker) in
            maker.top.equalTo(cancelButton.snp.bottom).offset(50)
            maker.left.right.equalToSuperview().inset(10)
            maker.height.equalTo(lineHeight+10*2)
        }
        textView.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.right.equalToSuperview().inset(10)
        }
        calculatelabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(cancelButton.snp.bottom).offset(200)
            maker.left.equalToSuperview().offset(25)
            maker.right.equalToSuperview().offset(-40)
            maker.height.equalTo(55)
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
        textView.resignFirstResponder()
    }
}

// MARK: - Private
extension InputTextViewController {

    private func getLinesArrayOfString(in label: UILabel) -> [String] {
        var linesArray = [String]()
        guard let text = label.text, let font = label.font else { return linesArray }
        let rect = label.frame
        let fontName: String
        if #available(iOS 13.0, *) {
            fontName = "TimesNewRomanPSMT" // iOS 13 下 fontName 会警告
        } else {
            fontName = font.fontName
        }
        let myFont: CTFont = CTFontCreateWithName(fontName as CFString, font.pointSize, nil)
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: myFont, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000), transform: .identity)
        
        let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else {return linesArray}
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange: CFRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString: String = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
}

// MARK: - UITextViewDelegate
extension InputTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let line = CGFloat(Int(textView.contentSize.height / lineHeight))
        let height: CGFloat = max(lineHeight * line + 10 * 2, textView.contentSize.height)
        textCoverView.snp.updateConstraints { (maker) in
            maker.height.equalTo(height)
        }
        
        calculatelabel.text = textView.text
        let arr = getLinesArrayOfString(in: calculatelabel)
        // mask
        print(arr)
    }
}

// MARK: - Notification
extension InputTextViewController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardFrameChanged(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let offset = UIScreen.main.bounds.height - frame.origin.y
        toolView.snp.remakeConstraints { (maker) in
            maker.left.right.equalToSuperview().inset(20)
            if offset == 0 {
                if #available(iOS 11.0, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
                } else {
                    maker.bottom.equalToSuperview().offset(-40)
                }
            } else {
                maker.bottom.equalToSuperview().offset(-offset-20)
            }
            maker.height.equalTo(30)
        }
        view.layoutIfNeeded()
    }
}
