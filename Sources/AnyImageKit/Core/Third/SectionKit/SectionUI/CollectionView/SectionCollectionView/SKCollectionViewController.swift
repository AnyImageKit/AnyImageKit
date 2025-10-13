// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

open class SKCollectionViewController: UIViewController {
    
    public typealias ControllerStyleBlock  = (_ controller: SKCollectionViewController) -> Void
    public typealias SectionViewStyleBlock = (_ view: SKCollectionView) -> Void
    public typealias VoidAsyncAction = () async -> Void
    
    public class EndPoint {
        
        public var before: ControllerStyleBlock?
        public var after: ControllerStyleBlock?
        public var animate: ControllerStyleBlock?
        
        public init(before: ControllerStyleBlock? = nil,
             after: ControllerStyleBlock? = nil,
             animate: ControllerStyleBlock? = nil) {
            self.before = before
            self.after = after
            self.animate = animate
        }
        
    }
    
    public class Events {
        public var viewDidLoad = [EndPoint]()
        public var viewDidAppear = [EndPoint]()
        public var viewTransition = [EndPoint]()
    }
    
    public class LayoutConstraints {
        var top, bottom, left, right: NSLayoutConstraint?
        var safeAreaTop: NSLayoutConstraint?
    }
    
    private var refreshableAction: VoidAsyncAction?
    public private(set) lazy var sectionView = SKCollectionView()
    public private(set) var isIgnoresSafeArea = false
    
    public var manager: SKCManager { sectionView.manager }
    public let events: Events = .init()
    public let layoutConstraint: LayoutConstraints = .init()
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        for event in events.viewDidLoad {
            event.before?(self)
        }
        super.viewDidLoad()
        if view.backgroundColor == nil {
            view.backgroundColor = .white
        }
        view.addSubview(sectionView)
        let safeArea = view.safeAreaLayoutGuide
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraint.safeAreaTop = layout(anchor1: sectionView.topAnchor, anchor2: safeArea.topAnchor, isActive: !isIgnoresSafeArea)
        layoutConstraint.top         = layout(anchor1: sectionView.topAnchor, anchor2: view.topAnchor, isActive: isIgnoresSafeArea)
        layoutConstraint.bottom      = layout(anchor1: sectionView.bottomAnchor, anchor2: view.bottomAnchor)
        layoutConstraint.right       = layout(anchor1: sectionView.rightAnchor, anchor2: safeArea.rightAnchor)
        layoutConstraint.left        = layout(anchor1: sectionView.leftAnchor, anchor2: safeArea.leftAnchor)
        for event in events.viewDidLoad {
            event.after?(self)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        for event in events.viewDidAppear {
            event.before?(self)
        }
        super.viewDidAppear(animated)
        for event in events.viewDidAppear {
            event.after?(self)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sectionView.collectionViewLayout.invalidateLayout()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for event in events.viewTransition {
            event.before?(self)
        }
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else {
            return
        }
#if targetEnvironment(macCatalyst)
        sectionView.collectionViewLayout.invalidateLayout()
        return
#endif
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            sectionView.collectionViewLayout.invalidateLayout()
            for event in events.viewTransition {
                event.animate?(self)
            }
        }, completion: { [weak self] context in
            guard let self = self else { return }
            for event in events.viewTransition {
                event.after?(self)
            }
        })
    }
    
}

public extension SKCollectionViewController {
    
    @discardableResult
    func onAppear(perform action: (() -> Void)? = nil) -> Self {
        events.viewDidAppear.append(.init(after: { controller in
            action?()
        }))
        return self
    }
    
}

public extension SKCollectionViewController {
    
    @discardableResult
    func ignoresSafeArea() -> Self {
        self.isIgnoresSafeArea = true
        layoutConstraint.top?.isActive = true
        layoutConstraint.safeAreaTop?.isActive = false
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        return self.controllerStyle { controller in
            controller.view.backgroundColor = color
            controller.sectionView.backgroundColor = color
        }
    }
    
}

public extension SKCollectionViewController {
    
    @discardableResult
    func refreshable(action: @escaping VoidAsyncAction) -> Self {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        sectionView.refreshControl = refreshControl
        self.refreshableAction = action
        return self
    }

    @objc private func refreshAction() {
        Task { @MainActor in
            await refreshableAction?()
            sectionView.refreshControl?.endRefreshing()
        }
    }
    
}

public extension SKCollectionViewController {
    
    @discardableResult
    func controllerStyle(_ block: @escaping ControllerStyleBlock) -> Self {
        if isViewLoaded {
            block(self)
        } else {
            events.viewDidLoad.append(.init(after: block))
        }
        return self
    }
    
    @discardableResult
    func sectionViewStyle(_ block: @escaping SectionViewStyleBlock) -> Self {
        return controllerStyle { controller in
            block(controller.sectionView)
        }
    }
    
    @discardableResult
    func reloadSections(_ section: any SKCBaseSectionProtocol) -> Self {
        return reloadSections([section])
    }
    
    @discardableResult
    func reloadSections(_ section: [any SKCBaseSectionProtocol]) -> Self {
        return controllerStyle { controller in
            controller.manager.reload(section)
        }
    }
    
}

private extension SKCollectionViewController {
    
    func layout(anchor1: NSLayoutYAxisAnchor, anchor2: NSLayoutYAxisAnchor, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = isActive
        return constraint
    }
    
    func layout(anchor1: NSLayoutXAxisAnchor, anchor2: NSLayoutXAxisAnchor, isActive: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = isActive
        return constraint
    }
    
}
#endif
