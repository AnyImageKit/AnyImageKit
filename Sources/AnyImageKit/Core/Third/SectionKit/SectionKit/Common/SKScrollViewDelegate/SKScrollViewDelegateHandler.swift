//
//  SKScrollViewDelegateHandler.swift
//  SectionKit2
//
//  Created by linhey on 2024/7/23.
//

import UIKit

public class SKScrollViewDelegateHandler: SKScrollViewDelegateObserverProtocol {
    
    // MARK: - Typealiases
    
    public typealias ScrollEvent = (_ scrollView: UIScrollView) -> Void
    public typealias ZoomEvent   = (_ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat) -> Void
    
    // MARK: - Public Properties
    
    /// 标识该 handler 的唯一 id，方便在多处使用时区分
    public var id: String = UUID().uuidString
    
    /// 是否启用该 handler，设置为 false 后将不会触发任何事件回调
    public var isEnabled: Bool = true
    
    // MARK: - Event Group
    
    /// 用于统一管理各类事件回调的结构
    struct EventGroup<Event> {
        public let onBegan: Event?
        public let onChanged: Event?
        public let onEnded: Event?
        
        public init(onBegan: Event? = nil,
                    onChanged: Event? = nil,
                    onEnded: Event? = nil) {
            self.onBegan = onBegan
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
    }
    
    // MARK: - Private Arrays
    
    /// 独立存放的滚动事件（非拖拽、减速、缩放），更常见所以单独列出
    private var didScrolls: [ScrollEvent] = []
    private var didAnimations: [ScrollEvent] = []
    
    /// 拖拽事件回调组
    private var drags: [EventGroup<ScrollEvent>] = []
    /// 减速事件回调组
    private var decelerates: [EventGroup<ScrollEvent>] = []
    /// 缩放事件回调组
    private var zooms: [EventGroup<ZoomEvent>] = []
    
    // MARK: - Initializer
    
    public init() {}
    
    // MARK: - Chain Registration Methods
    
    /// 注册滚动事件，支持链式调用
    @available(*, deprecated, renamed: "onChanged", message: "onChanged")
    @discardableResult
    public func didScroll(_ observe: @escaping ScrollEvent) -> Self {
        return onChanged(observe)
    }
    
    @discardableResult
    public func onChanged(_ observe: @escaping ScrollEvent) -> Self {
        self.didScrolls.append(observe)
        return self
    }
    
    @discardableResult
    public func onAnimation(_ observe: @escaping ScrollEvent) -> Self {
        self.didScrolls.append(observe)
        return self
    }
    
    /// 注册拖拽事件，支持链式调用
    @discardableResult
    public func onDrag(began: ScrollEvent? = nil,
                       changed: ScrollEvent? = nil,
                       ended: ScrollEvent? = nil) -> Self {
        drags.append(EventGroup(onBegan: began, onChanged: changed, onEnded: ended))
        return self
    }
    
    /// 注册减速事件，支持链式调用
    @discardableResult
    public func onDecelerate(began: ScrollEvent? = nil,
                             changed: ScrollEvent? = nil,
                             ended: ScrollEvent? = nil) -> Self {
        decelerates.append(EventGroup(onBegan: began, onChanged: changed, onEnded: ended))
        return self
    }
    
    /// 注册缩放事件，支持链式调用
    @discardableResult
    public func onZoom(began: ZoomEvent? = nil,
                       changed: ZoomEvent? = nil,
                       ended: ZoomEvent? = nil) -> Self {
        zooms.append(EventGroup(onBegan: began, onChanged: changed, onEnded: ended))
        return self
    }
    
    // MARK: - Private Dispatch Methods
    
    /// 分发简单的 "didScroll" 事件
    private func dispatchScrollEvents(_ items: [ScrollEvent],
                                      with scrollView: UIScrollView) {
        guard isEnabled else { return }
        items.forEach { $0(scrollView) }
    }
    
    /// 分发通用的事件组
    private func dispatchEvent<Event>(_ items: [EventGroup<Event>],
                                      began: Bool = false,
                                      changed: Bool = false,
                                      ended: Bool = false,
                                      block: (Event) -> Void) {
        guard isEnabled else { return }
        for group in items {
            if began   { group.onBegan.map(block) }
            if changed { group.onChanged.map(block) }
            if ended   { group.onEnded.map(block) }
        }
    }
    
    // MARK: - SKScrollViewDelegateObserverProtocol Methods
    
    /// 当 UIScrollView 滚动时触发
    public func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        dispatchScrollEvents(didScrolls, with: scrollView)
        if scrollView.isDragging {
            dispatchEvent(drags, changed: true) { event in
                event(scrollView)
            }
        } else if scrollView.isDecelerating {
            dispatchEvent(decelerates, changed: true) { event in
                event(scrollView)
            }
        }
    }
    
    /// 开始拖拽
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView, value: Void) {
        dispatchEvent(drags, began: true) { event in
            event(scrollView)
        }
    }
    
    /// 结束拖拽
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                         willDecelerate decelerate: Bool,
                                         value: Void) {
        dispatchEvent(drags, ended: true) { event in
            event(scrollView)
        }
    }
    
    /// 开始减速
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView, value: Void) {
        dispatchEvent(decelerates, began: true) { event in
            event(scrollView)
        }
    }
    
    /// 减速结束
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, value: Void) {
        dispatchEvent(decelerates, ended: true) { event in
            event(scrollView)
        }
    }
    
    /// 开始缩放
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView,
                                           with view: UIView?,
                                           value: Void) {
        dispatchEvent(zooms, began: true) { event in
            event(scrollView, view, scrollView.zoomScale)
        }
    }
    
    /// 缩放中
    public func scrollViewDidZoom(_ scrollView: UIScrollView, value: Void) {
        dispatchEvent(zooms, changed: true) { event in
            // 注意这里示例将 view 参数设为 nil，如果需要可以自行修改
            event(scrollView, nil, scrollView.zoomScale)
        }
    }
    
    /// 结束缩放
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                        with view: UIView?,
                                        atScale scale: CGFloat,
                                        value: Void) {
        dispatchEvent(zooms, ended: true) { event in
            event(scrollView, view, scale)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView, value: Void) {
        dispatchScrollEvents(didAnimations, with: scrollView)
    }
    
}
