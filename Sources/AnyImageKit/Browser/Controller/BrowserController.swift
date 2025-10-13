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

protocol BrowserChildController {
    var contentView: UIView { get }
}

open class BrowserController: AnyImageViewController {
    
    private class WeakBox {
        weak var controller: BrowserPreviewController?
        init(_ controller: BrowserPreviewController?) {
            self.controller = controller
        }
    }
    
    public var currentIndex: Int {
        get {
            pageManager.selection
        } set {
            pageManager.selection = newValue
        }
    }
    public let options: BrowserOptionsInfo
    public let pageManager: SKPageManager
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownSafeAreaInsets: UIEdgeInsets?
    private var isFirstLayout = true
    private var viewControllers: [WeakBox] = []
    
    public private(set) lazy var transition = getTransition()
    
    private let contentSafeAreaLayoutGuide = UILayoutGuide()
    
    public init(options: BrowserOptionsInfo) {
        self.options = options
        self.pageManager = .init()
        self.pageManager.selection = options.index
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transition
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        syncLayoutGuide(isAnimated: false)
    }
    
    // MARK: - Override Methods
    
    /// Updates the safe area layout guide for content.
    open func updateContentSafeAreaLayoutGuide(isAnimated: Bool, _ closure: (_ make: ConstraintMaker) -> Void) {
        contentSafeAreaLayoutGuide.snp.remakeConstraints(closure)
        syncLayoutGuide(isAnimated: isAnimated)
    }
    
    /// Called when the browser's page index changes.
    open func browser(_ browser: BrowserController, didChangeIndex index: Int) {
        
    }
    
    /// Called when the pan gesture for dismissal begins.
    open func browserDidBeginPan(_ browser: BrowserController) {
        
    }
    
    /// Called during the pan gesture, provides the current dismissal scale.
    open func browser(_ browser: BrowserController, didPanScale scale: CGFloat) {
        let alpha = scale * scale
        transition.presentationController?.maskAlpha = alpha
        (pageManager.currentModel?.controller as? BrowserPreviewController)?.hideToolBar(isHidden: true)
    }
    
    /// Called when the pan gesture ends. The `isExit` parameter indicates whether the view should be dismissed.
    open func browser(_ browser: BrowserController, didEndPanWithExit isExit: Bool) {
        if isExit {
            dismiss(animated: true, completion: nil)
        } else {
            (pageManager.currentModel?.controller as? BrowserPreviewController)?.hideToolBar(isHidden: false)
        }
    }
    
    /// Called when a single tap is detected in the browser.
    open func browserDidSingleTap(_ browser: BrowserController) {
        (pageManager.currentModel?.controller as? BrowserPreviewController)?.hideToolBar(isHidden: shouldHideToolBar(in: self), isAnimated: false)
    }
    
    /// Asks the delegate whether the toolbar should be hidden.
    open func shouldHideToolBar(in browser: BrowserController) -> Bool {
        return false
    }
}

// MARK: - UI
extension BrowserController {
    
    private func setupView() {
        view.addLayoutGuide(contentSafeAreaLayoutGuide)
        contentSafeAreaLayoutGuide.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageManager.spacing = 30
        pageManager.childs = options.resources.map { resource in
                .withController { [weak self] context in
                    guard let self = self else { return UIViewController() }
                    let controller = self.options.previewClass.init(options: self.options)
                    controller.config(resource)
                    controller.previewView.delegate = self
                    controller.needSyncLayoutGuideEvent.delegate(on: self) { (self, _)  in
                        self.syncLayoutGuide(isAnimated: false, force: true)
                    }
                    self.viewControllers.removeAll(where: { $0.controller == nil })
                    self.viewControllers.append(.init(controller))
                    return controller
                }
        }
        
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
    }
    
    private func getTransition() -> ScaleTransition {
        ScaleTransition { [weak self] in
            guard let self = self else { return nil }
            return options.relatedView?(pageManager.selection)
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
