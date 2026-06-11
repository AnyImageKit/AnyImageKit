//
//  BrowserPreviewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Combine
import SnapKit

public protocol BrowserControllerDelegate: AnyObject {
    
    func browser(_ browser: BrowserController, relatedViewAt index: Int) -> UIView?
    func browser(_ browser: BrowserController, singleTappedOnItem at: Int)
    func browserWillDismiss(_ browser: BrowserController)
    func browserDidDismiss(_ browser: BrowserController)
}

extension BrowserControllerDelegate {
    
    public func browser(_ browser: BrowserController, relatedViewAt index: Int) -> UIView? { return nil }
    public func browser(_ browser: BrowserController, singleTappedOnItem at: Int) { }
    public func browserWillDismiss(_ browser: BrowserController) { }
    public func browserDidDismiss(_ browser: BrowserController) { }
}

open class BrowserController: AnyImageViewController, BrowserOptionsConfigurable {
    
    private class WeakBox {
        weak var controller: BrowserPreviewController?
        init(_ controller: BrowserPreviewController?) {
            self.controller = controller
        }
    }
    
    public var currentIndex: Int {
        get {
            pageManager.currentIndex
        } set {
            pageManager.currentIndex = newValue
        }
    }
    public var options: BrowserOptionsInfo
    public let pageManager: SKPageManager
    open weak var browserDelegate: BrowserControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownSafeAreaInsets: UIEdgeInsets?
    private var isFirstLayout = true
    private var isFirstLoad = true
    private var viewControllers: [WeakBox] = []
    
    public private(set) lazy var transition = getTransition()
    
    private let contentSafeAreaLayoutGuide = UILayoutGuide()
    
    public private(set) lazy var closeButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.preferredSymbolConfigurationForImage = .init(pointSize: 14, weight: .regular)
            view.configuration = configuration
        } else { // TODO: need Test
            view.imageView?.contentMode = .scaleAspectFit
            view.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        return view
    }()
    public private(set) lazy var pageLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return view
    }()
    
    public init(options: BrowserOptionsInfo, delegate: BrowserControllerDelegate) {
        self.options = options
        self.browserDelegate = delegate
        self.pageManager = .init()
        super.init(nibName: nil, bundle: nil)
        self.currentIndex = options.index
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transition
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        update(options: options)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        syncLayoutGuide(isAnimated: false)
    }
        
    // MARK: - Override Methods
    
    open func update(options: BrowserOptionsInfo) {
        self.options = options
        transition.presentationController?.maskView.backgroundColor = options.theme[color: .background]
        setStatusBar(hidden: !options.showStatusBar)
        viewControllers.forEach {
            $0.controller?.update(options: options)
        }
        if #available(iOS 15.0, *) {
            closeButton.configuration?.baseForegroundColor = options.theme[color: .primary]
            closeButton.configuration?.image = options.theme[icon: .closeButton]
        } else {
            closeButton.tintColor = options.theme[color: .primary]
            closeButton.setImage(options.theme[icon: .closeButton], for: .normal)
        }
        
        pageLabel.textColor = options.theme[color: .primary]
        pageLabel.text = "\(options.index + 1)/\(options.resources.count)"
        
        options.theme.buttonConfiguration[.close]?.configuration(closeButton)
        options.theme.labelConfiguration[.page]?.configuration(pageLabel)
        
        viewControllers.forEach {
            if let controller = $0.controller {
                controller.previewView.config(options.resources[controller.index])
            }
        }
    }
    
    /// Updates the safe area layout guide for content.
    open func updateContentSafeAreaLayoutGuide(isAnimated: Bool, _ closure: (_ make: ConstraintMaker) -> Void) {
        contentSafeAreaLayoutGuide.snp.remakeConstraints(closure)
        syncLayoutGuide(isAnimated: isAnimated)
    }
    
    /// Called when the browser's page index changes.
    open func browser(_ browser: BrowserController, didChangeIndex index: Int) {
        pageLabel.text = "\(index + 1)/\(options.resources.count)"
    }
    
    /// Called when the pan gesture for dismissal begins.
    open func browserDidBeginPan(_ browser: BrowserController) {
        
    }
    
    /// Called during the pan gesture, provides the current dismissal scale.
    open func browser(_ browser: BrowserController, didPanScale scale: CGFloat) {
        let alpha = scale * scale
        transition.presentationController?.maskAlpha = alpha
        hideToolBar(isHidden: true)
    }
    
    /// Called when the pan gesture ends. The `isExit` parameter indicates whether the view should be dismissed.
    open func browser(_ browser: BrowserController, didEndPanWithExit isExit: Bool) {
        if isExit {
            dismiss()
        } else {
            hideToolBar(isHidden: false)
        }
    }
    
    /// Called when a single tap is detected in the browser.
    open func browserDidSingleTap(_ browser: BrowserController) {
        browserDelegate?.browser(self, singleTappedOnItem: currentIndex)
        switch options.singleTapAction {
        case .none:
            hideToolBar(isHidden: shouldHideToolBar(in: self), isAnimated: false)
        case .dismiss:
            dismiss()
        }
    }
    
    /// Asks the delegate whether the toolbar should be hidden.
    open func shouldHideToolBar(in browser: BrowserController) -> Bool {
        return false
    }
    
    open func hideToolBar(isHidden: Bool, isAnimated: Bool = true) {
        viewControllers.compactMap { $0.controller }.forEach({
            $0.hideToolBar(isHidden: isHidden, isAnimated: false)
        })
        closeButton.alpha = isHidden ? 0 : 1
        pageLabel.alpha = isHidden ? 0 : 1
    }
}

// MARK: - UI
extension BrowserController {
    
    private func setupPageManager() {
        pageManager.childs = options.resources.map { resource in
                .withController { [weak self] context in
                    guard let self = self else { return UIViewController() }
                    let controller = self.options.previewClass.init(options: self.options)
                    if let image = self.options.placeholdImage, self.isFirstLoad {
                        self.isFirstLoad = false
                        controller.placeholdImage = image
                    }
                    controller.config(resource)
                    controller.index = context.index
                    controller.hideToolBar(isHidden: self.shouldHideToolBar(in: self), isAnimated: false)
                    controller.previewView.delegate = self
                    controller.needSyncLayoutGuideEvent.delegate(on: self) { (self, _)  in
                        self.syncLayoutGuide(isAnimated: false, force: true)
                    }
                    self.viewControllers.removeAll(where: { $0.controller == nil })
                    self.viewControllers.append(.init(controller))
                    return controller
                }
        }
    }
    
    private func setupView() {
        view.addLayoutGuide(contentSafeAreaLayoutGuide)
        contentSafeAreaLayoutGuide.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageManager.spacing = 30
        setupPageManager()
        
        pageManager.$current
            .compactMap({ $0 })
            .sink { [weak self] content in
                guard let self = self else { return }
                self.browser(self, didChangeIndex: content.index)
            }.store(in: &cancellables)
        
        let pageController = SKPageViewController()
        pageController.set(manager: pageManager)
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageController.renderUI()
        view.backgroundColor = .clear
        
        view.addSubview(closeButton)
        view.addSubview(pageLabel)
        closeButton.snp.makeConstraints { make in
            make.top.left.equalTo(contentSafeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(35)
        }
        pageLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentSafeAreaLayoutGuide)
            make.centerY.equalTo(closeButton)
        }
    }
    
    private func getTransition() -> ScaleTransition {
        ScaleTransition(backgroundColor: options.theme[color: .background]) { [weak self] in
            guard let self = self else { return nil }
            return browserDelegate?.browser(self, relatedViewAt: self.currentIndex)
        } to: { [weak self] in
            guard let self = self else { return nil }
            self.view.layoutIfNeeded()
            let view = (pageManager.currentModel?.controller as? BrowserChildController)?.contentView
            return view
        }
    }
    
    private func syncLayoutGuide(isAnimated: Bool, force: Bool = false) {
        let guideFrame = contentSafeAreaLayoutGuide.layoutFrame
        let insets = UIEdgeInsets(
            top: guideFrame.minY - view.bounds.minY,
            left: guideFrame.minX - view.bounds.minX,
            bottom: view.bounds.maxY - guideFrame.maxY,
            right: view.bounds.maxX - guideFrame.maxX
        )

        if insets != lastKnownSafeAreaInsets || force {
            viewControllers.compactMap { $0.controller }.forEach { controller in
                controller.updateSafeArea(insets: insets, isAnimated: isAnimated)
            }
            self.lastKnownSafeAreaInsets = insets
        }
    }
    
    private func dismiss() {
        browserDelegate?.browserWillDismiss(self)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.browserDelegate?.browserDidDismiss(self)
        }
    }
}

// MARK: - Target
extension BrowserController {
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss()
    }
}

// MARK: - BrowserPreviewViewDelegate
extension BrowserController: BrowserPreviewViewDelegate {
    
    public func previewDidBeginPan(_ preview: BrowserPreviewView) {
        browserDidBeginPan(self)
    }
    
    public func preview(_ preview: BrowserPreviewView, didPanScale scale: CGFloat) {
        browser(self, didPanScale: scale)
    }
    
    public func preview(_ preview: BrowserPreviewView, didEndPanWithExit isExit: Bool) {
        browser(self, didEndPanWithExit: isExit)
    }
    
    public func previewDidSingleTap(_ preview: BrowserPreviewView) {
        browserDidSingleTap(self)
    }
    
}
