//
//  InputTextViewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/2.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class InputTextViewController: AnyImageViewController {
    
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView(image: coverImage)
        view.contentMode = .scaleAspectFill
        return view
    }()
    private lazy var coverView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(options.theme[string: .cancel], for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        view.backgroundColor = options.theme[color: .primary]
        view.setTitle(options.theme[string: .done], for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var toolView: EditorTextToolView = {
        let view = EditorTextToolView(frame: .zero, options: options, idx: data.colorIdx, isTextSelected: data.isTextSelected)
        view.delegate = self
        return view
    }()
    private var textLayer: CAShapeLayer?
    private lazy var textCoverView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    private lazy var textView: UITextView = {
        let view = MyUITextView()
        view.delegate = self
        view.backgroundColor = .clear
        view.keyboardAppearance = .dark
        view.returnKeyType = .done
        view.enablesReturnKeyAutomatically = true
        view.showsVerticalScrollIndicator = false
        view.font = options.textFont
        view.tintColor = options.theme[color: .primary]
        let color = options.textColors[data.colorIdx]
        view.textColor = data.isTextSelected ? color.subColor : color.color
        view.frame = CGRect(x: hInset, y: 0, width: UIScreen.main.bounds.width-hInset*4, height: lineHeight+vInset*2) // 预设
        view.textContainerInset = UIEdgeInsets.zero
        view.textContainer.lineFragmentPadding = 0
        return view
    }()
    /// 仅用于计算TextView最后一行的文本
    private lazy var calculateLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private let context: PhotoEditorContext
    private var options: EditorPhotoOptionsInfo {
        return context.options
    }
    private let coverImage: UIImage?
    private let data: TextData
    private let lineHeight: CGFloat
    private let vInset: CGFloat = 8
    private let hInset: CGFloat = 12
    private var isBegin: Bool = true
    private var containerSize: CGSize = .zero
    
    init(context: PhotoEditorContext, data: TextData, coverImage: UIImage?) {
        self.context = context
        self.coverImage = coverImage
        self.data = data
        self.lineHeight = context.options.textFont.lineHeight
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newSize = view.frame.size
        if containerSize != .zero, containerSize != newSize {
            view.endEditing(true)
            dismiss(animated: false, completion: nil)
            return
        }
        containerSize = newSize
        
        if isBegin {
            isBegin = false
            if !data.text.isEmpty {
                textView.text = data.text
                textViewDidChange(textView)
                updateShadow()
            }
            textView.becomeFirstResponder()
        }
    }
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(coverView)
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(textCoverView)
        textCoverView.addSubview(textView)
        view.addSubview(calculateLabel)
        view.addSubview(toolView)
        
        coverImageView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            if let image = coverImage {
                let height = UIScreen.main.bounds.width * image.size.height / image.size.width
                maker.height.equalTo(height)
            } else {
                maker.height.equalTo(0)
            }
        }
        coverView.snp.makeConstraints { maker in
            maker.edges.equalTo(coverImageView)
        }
        cancelButton.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                let topOffset = ScreenHelper.statusBarFrame.height <= 20 ? 20 : 10
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(topOffset)
            } else {
                maker.top.equalToSuperview().offset(30)
            }
            maker.left.equalToSuperview().offset(15)
        }
        doneButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(cancelButton)
            maker.right.equalToSuperview().offset(-15)
        }
        layoutToolView()
        textCoverView.snp.makeConstraints { maker in
            maker.top.equalTo(cancelButton.snp.bottom).offset(50)
            maker.left.right.equalToSuperview().inset(hInset)
            maker.height.equalTo(lineHeight + vInset * 2)
        }
        textView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(vInset)
            maker.bottom.equalToSuperview()
            maker.left.right.equalToSuperview().inset(hInset)
        }
        calculateLabel.snp.makeConstraints { maker in
            maker.top.equalTo(cancelButton.snp.bottom).offset(250)
            maker.left.right.equalTo(textView)
            maker.height.greaterThanOrEqualTo(55)
        }
        
        options.theme.buttonConfiguration[.cancel]?.configuration(cancelButton)
        options.theme.buttonConfiguration[.done]?.configuration(doneButton)
    }
    
    private func layoutToolView(bottonOffset: CGFloat = 0) {
        toolView.snp.remakeConstraints { maker in
            maker.left.right.equalToSuperview()
            if bottonOffset == 0 {
                if #available(iOS 11.0, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
                } else {
                    maker.bottom.equalToSuperview().offset(-40)
                }
            } else {
                maker.bottom.equalToSuperview().offset(-bottonOffset-20)
            }
            maker.height.equalTo(40)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown:
            return .portrait
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
}

// MARK: - Target
extension InputTextViewController {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        context.action(.textCancel)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        updateTextCoverView()
        textView.resignFirstResponder()
        data.frame = .zero
        data.text = textView.text
        data.imageData = textCoverView.screenshot().pngData() ?? Data()
        context.action(.textDone(data))
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private
extension InputTextViewController {
    
    /// 设置蒙层
    private func setupMaskLayer(_ height: CGFloat = 0) {
        let height = height == 0 ? textCoverView.bounds.height : height
        textLayer?.removeFromSuperlayer()
        let array = textView.getSeparatedLines()
        if array.isEmpty { return }
        
        updateCalculateLabel(string: array.last!)
        let lastLineWidth: CGFloat
        if options.calculateTextLastLineMask {
            lastLineWidth = calculateLabel.intrinsicContentSize.width + (hInset * 2)
        } else {
            lastLineWidth = array.count == 1 ? calculateLabel.intrinsicContentSize.width + (hInset * 2) : textCoverView.bounds.width
        }
        textLayer = createMaskLayer(CGSize(width: textCoverView.bounds.width, height: height), lastLineWidth: lastLineWidth, hasMultiLine: array.count > 1)
        textCoverView.layer.insertSublayer(textLayer!, at: 0)
    }
    
    /// 创建蒙层
    private func createMaskLayer(_ size: CGSize, lastLineWidth: CGFloat, hasMultiLine: Bool) -> CAShapeLayer {
        let radius: CGFloat = 12
        let lastLineWidth = lastLineWidth < size.width ? lastLineWidth : size.width
        let width: CGFloat = !hasMultiLine ? lastLineWidth : size.width
        let height: CGFloat = size.height
        let lastLineHeight: CGFloat = lineHeight
        
        let bezier: UIBezierPath
        if hasMultiLine && width - lastLineWidth > (hInset * 2) { // 一半的情况
            bezier = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), byRoundingCorners: [.topLeft, .topRight, .bottomLeft], cornerRadii: CGSize(width: radius, height: radius))
            let cropBezier1 = UIBezierPath(roundedRect: CGRect(x: lastLineWidth, y: height-lastLineHeight, width: width-lastLineWidth, height: lastLineHeight), byRoundingCorners: .topLeft, cornerRadii: CGSize(width: radius, height: radius))
            bezier.append(cropBezier1)
            let cropBezier2 = createReversePath(CGPoint(x: lastLineWidth-radius, y: height-radius), radius: radius)
            bezier.append(cropBezier2)
            let cropBezier3 = createReversePath(CGPoint(x: width-radius, y: height-lastLineHeight-radius), radius: radius)
            bezier.append(cropBezier3)
        } else {
            bezier = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: radius)
        }
        
        let layer = CAShapeLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.path = bezier.cgPath
        layer.fillRule = .evenOdd
        layer.cornerRadius = radius
        let color = options.textColors[data.colorIdx]
        layer.fillColor = data.isTextSelected ? color.color.withAlphaComponent(0.95).cgColor : nil
        return layer
    }
    
    /// 创建反向扇形图形
    private func createReversePath(_ origin: CGPoint, radius: CGFloat) -> UIBezierPath {
        let rect = CGRect(origin: origin, size: CGSize(width: radius, height: radius))
        let cropBezier = UIBezierPath(rect: rect)
        cropBezier.move(to: origin)
        cropBezier.addArc(withCenter: origin, radius: radius, startAngle: CGFloat.pi/2, endAngle: 0, clockwise: false)
        return cropBezier.reversing()
    }
    
    /// 仅单行文本时，更新实际输出视图的宽度
    private func updateTextCoverView() {
        let array = textView.getSeparatedLines()
        if array.count == 1 {
            updateCalculateLabel(string: array.last!)
            let lastLineWidth = calculateLabel.intrinsicContentSize.width + (hInset * 2)
            let offset = textCoverView.bounds.width - lastLineWidth + hInset
            
            // For iPad
            var frame = textCoverView.frame
            frame.size.width = lastLineWidth
            textCoverView.frame = frame
            
            textCoverView.snp.updateConstraints { maker in
                maker.right.equalToSuperview().offset(-offset)
            }
        }
    }
    
    /// 更新计算文本的内容
    private func updateCalculateLabel(string: String) {
        guard var attr = textView.attributedText else { return }
        attr = attr.attributedSubstring(from: (attr.string as NSString).range(of: string))
        calculateLabel.attributedText = attr
    }
    
    /// 设置文本阴影
    private func updateShadow() {
        if data.isTextSelected {
            textView.layer.removeSketchShadow()
        } else {
            if let shadow = options.textColors[data.colorIdx].shadow {
                textView.layer.applySketchShadow(with: shadow)
            } else {
                textView.layer.removeSketchShadow()
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension InputTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let line = CGFloat(textView.getSeparatedLines().count)
        let height: CGFloat = max(lineHeight * line, textView.contentSize.height) + vInset * 2
        textCoverView.snp.updateConstraints { maker in
            maker.height.equalTo(height)
        }
        setupMaskLayer(height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.setContentOffset(.zero, animated: false)
        if text == "\n" {
            doneButtonTapped(doneButton)
            return false
        }
        return true
    }
}

// MARK: - EditorTextToolViewDelegate
extension InputTextViewController: EditorTextToolViewDelegate {
    
    func textToolView(_ toolView: EditorTextToolView, textButtonTapped isSelected: Bool) {
        data.isTextSelected = isSelected
        let color = options.textColors[data.colorIdx]
        textView.textColor = data.isTextSelected ? color.subColor : color.color
        setupMaskLayer()
        updateShadow()
        trackObserver?.track(event: .editorPhotoTextSwitch, userInfo: [.isOn: isSelected])
    }
    
    func textToolView(_ toolView: EditorTextToolView, colorDidChange idx: Int) {
        data.colorIdx = idx
        let color = options.textColors[data.colorIdx]
        textView.textColor = data.isTextSelected ? color.subColor : color.color
        if data.isTextSelected {
            setupMaskLayer()
        }
        updateShadow()
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
        layoutToolView(bottonOffset: offset)
        view.layoutIfNeeded()
    }
}

extension UITextView {
    
    /// 计算行数
    func getSeparatedLines() -> [String] {
        var linesArray: [String] = []
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        let path = CGMutablePath()
        
        // size needs to be adjusted, because frame might change because of intelligent word wrapping of iOS
        let size = sizeThatFits(CGSize(width: self.frame.width, height: .greatestFiniteMagnitude))
        path.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height + 50), transform: .identity)
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else { return linesArray }
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
}

private final class MyUITextView: UITextView {
    
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        return
    }
}
