//
//  PickerThumbnailPreviewView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/11/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import SnapKit

protocol PickerThumbnailPreviewViewDelegate: AnyObject {
    func thumbnailPreviewView(_ view: PickerThumbnailPreviewView, didSelectAt index: Int)
}

private enum Constants {
    static let thumbnailWidth: CGFloat = 30
    static let thumbnailHeight: CGFloat = 45
    static let centerSpacing: CGFloat = 12
    static let normalSpacing: CGFloat = 4
}

final class PickerThumbnailPreviewView: UIView {
    
    weak var delegate: PickerThumbnailPreviewViewDelegate?
    
    var currentIndex: Int = 0 {
        didSet {
            guard !isSyncingCurrentIndex else { return }
            scrollToItem(at: currentIndex, animated: true)
        }
    }
    
    private var assets: [Asset] = []
    private var options: PickerOptionsInfo?
    private weak var manager: PickerManager?
    private var lastNotifiedIndex = -1
    private var isAnimating = false
    private var isUserScrolling = false
    private var isExternalUpdate = false
    private var isSyncingCurrentIndex = false
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    /// 防闪烁状态：过滤翻页完成后的残影 scroll 事件
    private var lastExternalToIndex: Int = -1
    private var lastExternalProgress: CGFloat = 0
    private var ignoreResidualScroll = false
    private var isIgnoringExternalScroll = false
    
    private lazy var layout: ThumbnailLayout = {
        let layout = ThumbnailLayout()
        layout.normalItemSize = CGSize(width: Constants.thumbnailWidth, height: Constants.thumbnailHeight)
        layout.maxCenterHeight = Constants.thumbnailHeight
        layout.assetsProvider = { [weak self] in self?.assets ?? [] }
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.decelerationRate = .normal
        view.delegate = self
        view.dataSource = self
        view.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        feedbackGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionInsetIfNeeded()
        updateGradientMask()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        layer.mask = gradientMaskLayer
    }
    
    private let gradientMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            CGColor(gray: 1, alpha: 0), CGColor(gray: 1, alpha: 0), CGColor(gray: 1, alpha: 1),
            CGColor(gray: 1, alpha: 1), CGColor(gray: 1, alpha: 0), CGColor(gray: 1, alpha: 0)
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    private func updateGradientMask() {
        guard bounds.width > 0 else { return }
        gradientMaskLayer.frame = bounds
        let fadeWidth: CGFloat = 15
        let fadeWidth2: CGFloat = 40
        let leftStop = NSNumber(value: Float(fadeWidth / bounds.width))
        let leftStop2 = NSNumber(value: Float(fadeWidth2 / bounds.width))
        let rightStop = NSNumber(value: Float(1 - fadeWidth / bounds.width))
        let rightStop2 = NSNumber(value: Float(1 - fadeWidth2 / bounds.width))
        gradientMaskLayer.locations = [0, leftStop, leftStop2, rightStop2, rightStop, 1]
    }
    
    func configure(with assets: [Asset], manager: PickerManager, currentIndex: Int = 0) {
        self.assets = assets
        self.manager = manager
        self.currentIndex = currentIndex
        self.lastNotifiedIndex = currentIndex
        layout.setState(.expanded(centerIndex: currentIndex))
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollToItem(at: currentIndex, animated: false)
        }
    }
    
    func reloadSelectionState() {
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard indexPath.item < assets.count,
                  let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell else {
                continue
            }
            cell.configure(with: assets[indexPath.item], options: options, manager: manager)
        }
    }
    
    func setCurrentIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < assets.count else { return }
        isSyncingCurrentIndex = true
        currentIndex = index
        isSyncingCurrentIndex = false
        lastNotifiedIndex = index
        // 重置防闪烁状态
        lastExternalToIndex = -1
        lastExternalProgress = 0
        ignoreResidualScroll = false
        isIgnoringExternalScroll = true
        DispatchQueue.main.async { [weak self] in
            self?.isIgnoringExternalScroll = false
        }
        guard !isUserScrolling else { return }
        scrollToItem(at: index, animated: animated)
    }
    
    func updateScrollProgress(fromIndex: Int, toIndex: Int, progress: CGFloat) {
        guard !isUserScrolling else { return }
        guard !isIgnoringExternalScroll else { return }
        guard fromIndex >= 0 && fromIndex < assets.count,
              toIndex >= 0 && toIndex < assets.count else {
            return
        }
        
        // 方向/目标改变时重置跟踪
        if toIndex != lastExternalToIndex {
            lastExternalToIndex = toIndex
            lastExternalProgress = 0
            ignoreResidualScroll = false
        }
        
        // 检测残影事件：同一转场对 progress 从 >0.8 骤降 >0.7
        if !ignoreResidualScroll && lastExternalProgress > 0.8 && (lastExternalProgress - progress) > 0.7 {
            ignoreResidualScroll = true
        }
        lastExternalProgress = progress
        if ignoreResidualScroll { return }
        
        let clampedProgress = max(0, min(1, progress))
        isExternalUpdate = true
        isAnimating = false
        
        let fromOffset = calculateExpandedOffset(for: fromIndex)
        let toOffset = calculateExpandedOffset(for: toIndex)
        
        if clampedProgress >= 0.98 {
            layout.setState(.expanded(centerIndex: toIndex))
            collectionView.setContentOffset(CGPoint(x: toOffset, y: 0), animated: false)
            collectionView.layoutIfNeeded()
            isIgnoringExternalScroll = true
        } else {
            layout.setState(.transition(fromIndex: fromIndex, toIndex: toIndex, progress: clampedProgress))
            let interpolatedOffset = fromOffset + (toOffset - fromOffset) * clampedProgress
            collectionView.setContentOffset(CGPoint(x: interpolatedOffset, y: 0), animated: false)
        }
    }
    
    func scrollToItem(at index: Int, animated: Bool) {
        guard index >= 0 && index < assets.count else { return }
        let targetOffset = calculateExpandedOffset(for: index)
        
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                self.layout.setState(.expanded(centerIndex: index))
                self.collectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
                self.collectionView.layoutIfNeeded()
            } completion: { _ in
                self.isAnimating = false
            }
        } else {
            layout.setState(.expanded(centerIndex: index))
            collectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
            collectionView.layoutIfNeeded()
        }
    }
    
    private func updateCollectionInsetIfNeeded() {
        let horizontalInset = max(0, (bounds.width - layout.normalItemSize.width) / 2)
        let inset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        if collectionView.contentInset != inset {
            collectionView.contentInset = inset
            collectionView.scrollIndicatorInsets = inset
        }
    }
    
    private func calculateExpandedOffset(for index: Int) -> CGFloat {
        let itemCenterX = ThumbnailLayout.calculateExpandedCenterX(
            for: index,
            assets: assets,
            normalItemSize: layout.normalItemSize,
            maxCenterHeight: layout.maxCenterHeight
        )
        return itemCenterX - collectionView.bounds.width / 2
    }
    
    private func calculateCollapsedOffset(for index: Int) -> CGFloat {
        let itemCenterX = ThumbnailLayout.calculateCollapsedCenterX(
            for: index,
            normalItemSize: layout.normalItemSize
        )
        return itemCenterX - collectionView.bounds.width / 2
    }
    
    private func calculateCollapsedCenterIndex() -> Int {
        guard assets.count > 0 else { return 0 }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let itemStride = layout.normalItemSize.width + Constants.normalSpacing
        guard itemStride > 0 else { return 0 }
        let index = Int(round((centerX - layout.normalItemSize.width / 2) / itemStride))
        return max(0, min(assets.count - 1, index))
    }
    
    private func calculateExpandedCenterIndex() -> Int {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        return ThumbnailLayout.calculateClosestExpandedIndex(
            to: centerX,
            assets: assets,
            normalItemSize: layout.normalItemSize,
            maxCenterHeight: layout.maxCenterHeight,
            itemCount: assets.count
        )
    }
    
    private func notifyCenterIndexIfChanged() {
        let centerIndex = calculateCollapsedCenterIndex()
        if centerIndex != lastNotifiedIndex && centerIndex >= 0 && centerIndex < assets.count {
            lastNotifiedIndex = centerIndex
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
            delegate?.thumbnailPreviewView(self, didSelectAt: centerIndex)
        }
    }
    
    private func scrollToNearestItemWithAnimation() {
        let closestIndex = calculateCollapsedCenterIndex()
        if closestIndex != lastNotifiedIndex {
            lastNotifiedIndex = closestIndex
            delegate?.thumbnailPreviewView(self, didSelectAt: closestIndex)
        }
        setCurrentIndex(closestIndex, animated: true)
    }
    
    private func stopProgrammaticAnimations() {
        if let presentationLayer = collectionView.layer.presentation() {
            let visibleOffsetX = presentationLayer.bounds.origin.x
            collectionView.layer.removeAllAnimations()
            layer.removeAllAnimations()
            UIView.performWithoutAnimation {
                collectionView.setContentOffset(
                    CGPoint(x: visibleOffsetX, y: collectionView.contentOffset.y),
                    animated: false
                )
                collectionView.layoutIfNeeded()
            }
        } else {
            collectionView.layer.removeAllAnimations()
            layer.removeAllAnimations()
        }
        isAnimating = false
    }
}

extension PickerThumbnailPreviewView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        cell.configure(with: assets[indexPath.item], options: options, manager: manager)
        return cell
    }
}

extension PickerThumbnailPreviewView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        self.options = options
        collectionView.reloadData()
    }
}

extension PickerThumbnailPreviewView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        lastNotifiedIndex = index
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
        scrollToItem(at: index, animated: true)
        delegate?.thumbnailPreviewView(self, didSelectAt: index)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        isExternalUpdate = false
        feedbackGenerator.prepare()
        
        let centerIndex = calculateExpandedCenterIndex()
        stopProgrammaticAnimations()
        layout.setState(.collapsed)
        collectionView.setContentOffset(CGPoint(x: calculateCollapsedOffset(for: centerIndex), y: 0), animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 仅在用户手指触摸期间通知页面变化（不在惯性减速阶段），与竞品行为一致
        if isUserScrolling && !isExternalUpdate && scrollView.isDragging {
            notifyCenterIndexIfChanged()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isUserScrolling = true
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        // 计算 UIKit 惯性的目标位置对应的最近 item，将 targetContentOffset 对齐到该 item 中心
        let proposedOffsetX = targetContentOffset.pointee.x
        let proposedCenterX = proposedOffsetX + collectionView.bounds.width / 2
        let itemWidth = Constants.thumbnailWidth + Constants.normalSpacing
        let targetIndex = max(0, min(assets.count - 1, Int(round((proposedCenterX - Constants.thumbnailWidth / 2) / itemWidth))))
        let snappedCenterX = ThumbnailLayout.calculateCollapsedCenterX(
            for: targetIndex,
            normalItemSize: layout.normalItemSize
        )
        targetContentOffset.pointee.x = snappedCenterX - collectionView.bounds.width / 2
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isUserScrolling = false
            scrollToNearestItemWithAnimation()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserScrolling = false
        scrollToNearestItemWithAnimation()
    }
}

private final class ThumbnailLayout: UICollectionViewLayout {
    
    enum State: Equatable {
        case collapsed
        case expanded(centerIndex: Int)
        case transition(fromIndex: Int, toIndex: Int, progress: CGFloat)
    }
    
    var normalItemSize: CGSize = CGSize(width: 20, height: 30)
    var maxCenterHeight: CGFloat = 30
    var assetsProvider: (() -> [Asset])?
    
    private var state: State = .collapsed
    private var cachedContentSize: CGSize = .zero
    private var cachedItemCount: Int = 0
    private var cachedAssets: [Asset] = []
    private var cachedCenterY: CGFloat = 0
    
    func setState(_ state: State) {
        self.state = state
        invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let itemCount = collectionView.numberOfItems(inSection: 0)
        cachedItemCount = itemCount
        guard itemCount > 0 else {
            cachedContentSize = .zero
            return
        }
        
        cachedAssets = assetsProvider?() ?? []
        cachedCenterY = collectionView.bounds.height / 2
        
        // 计算 contentSize（O(1)，不遍历所有 item）
        cachedContentSize = calculateContentSize(state: state, itemCount: itemCount, assets: cachedAssets, collectionView: collectionView)
    }
    
    override var collectionViewContentSize: CGSize {
        cachedContentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard cachedItemCount > 0 else { return nil }
        
        switch state {
        case .collapsed:
            let range = collapsedVisibleRange(in: rect, itemCount: cachedItemCount)
            return makeCollapsedAttributes(range: range, centerY: cachedCenterY)
        case .expanded(let centerIndex):
            let range = expandedVisibleRange(in: rect, centerIndex: centerIndex, itemCount: cachedItemCount, assets: cachedAssets)
            return makeExpandedAttributes(centerIndex: centerIndex, range: range, assets: cachedAssets, centerY: cachedCenterY)
        case .transition(let fromIndex, let toIndex, let progress):
            let range1 = expandedVisibleRange(in: rect, centerIndex: fromIndex, itemCount: cachedItemCount, assets: cachedAssets)
            let range2 = expandedVisibleRange(in: rect, centerIndex: toIndex, itemCount: cachedItemCount, assets: cachedAssets)
            let mergedRange = min(range1.lowerBound, range2.lowerBound)..<max(range1.upperBound, range2.upperBound)
            return makeTransitionAttributes(fromIndex: fromIndex, toIndex: toIndex, progress: progress, range: mergedRange, assets: cachedAssets, centerY: cachedCenterY)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item >= 0 && indexPath.item < cachedItemCount else { return nil }
        return makeAttributeForItem(at: indexPath.item)
    }
    
    private func makeAttributeForItem(at index: Int) -> UICollectionViewLayoutAttributes {
        let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
        switch state {
        case .collapsed:
            let itemStride = normalItemSize.width + Constants.normalSpacing
            attr.frame = CGRect(
                x: CGFloat(index) * itemStride,
                y: cachedCenterY - normalItemSize.height / 2,
                width: normalItemSize.width,
                height: normalItemSize.height
            )
            attr.zIndex = 1
        case .expanded(let centerIndex):
            let centerWidth = Self.calculateCenterItemWidth(
                for: cachedAssets.indices.contains(centerIndex) ? cachedAssets[centerIndex] : nil,
                maxHeight: maxCenterHeight, minWidth: normalItemSize.width
            )
            let isCenterItem = index == centerIndex
            let size: CGSize = isCenterItem ? CGSize(width: centerWidth, height: maxCenterHeight) : normalItemSize
            let x = expandedItemX(for: index, centerIndex: centerIndex, centerWidth: centerWidth)
            attr.frame = CGRect(x: x, y: cachedCenterY - size.height / 2, width: size.width, height: size.height)
            attr.zIndex = isCenterItem ? 1000 : max(1, 1000 - abs(index - centerIndex))
        case .transition(let fromIndex, let toIndex, let progress):
            let fromCW = Self.calculateCenterItemWidth(
                for: cachedAssets.indices.contains(fromIndex) ? cachedAssets[fromIndex] : nil,
                maxHeight: maxCenterHeight, minWidth: normalItemSize.width
            )
            let toCW = Self.calculateCenterItemWidth(
                for: cachedAssets.indices.contains(toIndex) ? cachedAssets[toIndex] : nil,
                maxHeight: maxCenterHeight, minWidth: normalItemSize.width
            )
            let fromIsCenter = index == fromIndex
            let toIsCenter = index == toIndex
            let fromSize: CGSize = fromIsCenter ? CGSize(width: fromCW, height: maxCenterHeight) : normalItemSize
            let toSize: CGSize = toIsCenter ? CGSize(width: toCW, height: maxCenterHeight) : normalItemSize
            let fromX = expandedItemX(for: index, centerIndex: fromIndex, centerWidth: fromCW)
            let toX = expandedItemX(for: index, centerIndex: toIndex, centerWidth: toCW)
            attr.frame = CGRect(
                x: fromX + (toX - fromX) * progress,
                y: (cachedCenterY - fromSize.height / 2) + ((cachedCenterY - toSize.height / 2) - (cachedCenterY - fromSize.height / 2)) * progress,
                width: fromSize.width + (toSize.width - fromSize.width) * progress,
                height: fromSize.height + (toSize.height - fromSize.height) * progress
            )
            attr.zIndex = max(
                fromIsCenter ? 1000 : max(1, 1000 - abs(index - fromIndex)),
                toIsCenter ? 1000 : max(1, 1000 - abs(index - toIndex))
            )
        }
        return attr
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return collectionView.bounds.size != newBounds.size
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        proposedContentOffset
    }
    
    // MARK: - Content Size (O(1))
    
    private func calculateContentSize(state: State, itemCount: Int, assets: [Asset], collectionView: UICollectionView) -> CGSize {
        let height = collectionView.bounds.height
        let width: CGFloat
        switch state {
        case .collapsed:
            width = CGFloat(itemCount) * normalItemSize.width + CGFloat(max(0, itemCount - 1)) * Constants.normalSpacing
        case .expanded(let centerIndex):
            width = expandedContentWidth(centerIndex: centerIndex, itemCount: itemCount, assets: assets)
        case .transition(let fromIndex, let toIndex, let progress):
            let fromW = expandedContentWidth(centerIndex: fromIndex, itemCount: itemCount, assets: assets)
            let toW = expandedContentWidth(centerIndex: toIndex, itemCount: itemCount, assets: assets)
            width = fromW + (toW - fromW) * progress
        }
        return CGSize(width: width, height: height)
    }
    
    private func expandedContentWidth(centerIndex: Int, itemCount: Int, assets: [Asset]) -> CGFloat {
        // All items are normalItemSize except centerIndex which is wider, and centerIndex has centerSpacing on both sides
        let centerWidth = Self.calculateCenterItemWidth(
            for: assets.indices.contains(centerIndex) ? assets[centerIndex] : nil,
            maxHeight: maxCenterHeight,
            minWidth: normalItemSize.width
        )
        let normalCount = max(0, itemCount - 1)
        let totalItemWidth = CGFloat(normalCount) * normalItemSize.width + centerWidth
        // Spacing: centerSpacing on both sides of center item (2 total if center is not at edge), normalSpacing for the rest
        let centerSpacingCount: Int
        if itemCount <= 1 {
            centerSpacingCount = 0
        } else if centerIndex == 0 || centerIndex == itemCount - 1 {
            centerSpacingCount = 1
        } else {
            centerSpacingCount = 2
        }
        let normalSpacingCount = max(0, itemCount - 1 - centerSpacingCount)
        let totalSpacing = CGFloat(centerSpacingCount) * Constants.centerSpacing + CGFloat(normalSpacingCount) * Constants.normalSpacing
        return totalItemWidth + totalSpacing
    }
    
    // MARK: - Visible Range Calculation (O(1))
    
    private func collapsedVisibleRange(in rect: CGRect, itemCount: Int) -> Range<Int> {
        let itemStride = normalItemSize.width + Constants.normalSpacing
        guard itemStride > 0 else { return 0..<itemCount }
        let start = max(0, Int(floor(rect.minX / itemStride)))
        let end = min(itemCount, Int(ceil(rect.maxX / itemStride)) + 1)
        return start..<max(start, end)
    }
    
    private func expandedVisibleRange(in rect: CGRect, centerIndex: Int, itemCount: Int, assets: [Asset]) -> Range<Int> {
        // 中心 item 宽度不同，但其他 item 都是 normalItemSize
        // 用公式近似：先用 normalSpacing stride 估算，再向两侧各扩展几个 item 作为安全余量
        let itemStride = normalItemSize.width + Constants.normalSpacing
        guard itemStride > 0 else { return 0..<itemCount }
        let roughStart = max(0, Int(floor(rect.minX / itemStride)) - 2)
        let roughEnd = min(itemCount, Int(ceil(rect.maxX / itemStride)) + 3)
        return roughStart..<max(roughStart, roughEnd)
    }
    
    // MARK: - Attribute Generation (only for visible range)
    
    private func makeCollapsedAttributes(range: Range<Int>, centerY: CGFloat) -> [UICollectionViewLayoutAttributes] {
        let itemStride = normalItemSize.width + Constants.normalSpacing
        let y = centerY - normalItemSize.height / 2
        return range.map { index in
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attr.frame = CGRect(
                x: CGFloat(index) * itemStride,
                y: y,
                width: normalItemSize.width,
                height: normalItemSize.height
            )
            attr.zIndex = 1
            return attr
        }
    }
    
    /// O(1) 计算 expanded 状态下某个 item 的 x 起始位置
    private func expandedItemX(for index: Int, centerIndex: Int, centerWidth: CGFloat) -> CGFloat {
        if index <= centerIndex {
            // items before center: all normal width + normalSpacing, except the gap before center uses centerSpacing
            let normalItems = index
            var x = CGFloat(normalItems) * normalItemSize.width
            if index <= centerIndex && index > 0 {
                // spacing: (index-1) normalSpacing + 1 centerSpacing (before center)
                let spacingBeforeCenter = min(index, centerIndex)
                x += CGFloat(max(0, spacingBeforeCenter - 1)) * Constants.normalSpacing
                if index >= 1 { x += Constants.centerSpacing } // the gap just before center item when we reach or pass it
            } else if index > 0 {
                x += CGFloat(index - 1) * Constants.normalSpacing + Constants.centerSpacing
            }
            // Wait, let me simplify: for index <= centerIndex
            // items 0..<centerIndex are normal. Between them: normalSpacing, except gap at (centerIndex-1, centerIndex) is centerSpacing
            // x(index) = index * normalWidth + (index-1)*normalSpacing + (centerSpacing - normalSpacing) if index == centerIndex
            // Actually let me just compute directly:
            if index < centerIndex {
                return CGFloat(index) * (normalItemSize.width + Constants.normalSpacing)
            } else {
                // index == centerIndex
                if centerIndex == 0 { return 0 }
                return CGFloat(centerIndex - 1) * (normalItemSize.width + Constants.normalSpacing) + normalItemSize.width + Constants.centerSpacing
            }
        } else {
            // index > centerIndex
            // x = expanded position of center item + centerWidth + centerSpacing + (index - centerIndex - 1) * (normalWidth + normalSpacing)
            let centerX = expandedItemX(for: centerIndex, centerIndex: centerIndex, centerWidth: centerWidth)
            return centerX + centerWidth + Constants.centerSpacing + CGFloat(index - centerIndex - 1) * (normalItemSize.width + Constants.normalSpacing)
        }
    }
    
    private func makeExpandedAttributes(
        centerIndex: Int,
        range: Range<Int>,
        assets: [Asset],
        centerY: CGFloat
    ) -> [UICollectionViewLayoutAttributes] {
        let centerWidth = Self.calculateCenterItemWidth(
            for: assets.indices.contains(centerIndex) ? assets[centerIndex] : nil,
            maxHeight: maxCenterHeight,
            minWidth: normalItemSize.width
        )
        return range.map { index in
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            let isCenterItem = index == centerIndex
            let size: CGSize = isCenterItem
                ? CGSize(width: centerWidth, height: maxCenterHeight)
                : normalItemSize
            let x = expandedItemX(for: index, centerIndex: centerIndex, centerWidth: centerWidth)
            attr.frame = CGRect(x: x, y: centerY - size.height / 2, width: size.width, height: size.height)
            attr.zIndex = isCenterItem ? 1000 : max(1, 1000 - abs(index - centerIndex))
            return attr
        }
    }
    
    private func makeTransitionAttributes(
        fromIndex: Int,
        toIndex: Int,
        progress: CGFloat,
        range: Range<Int>,
        assets: [Asset],
        centerY: CGFloat
    ) -> [UICollectionViewLayoutAttributes] {
        let fromCenterWidth = Self.calculateCenterItemWidth(
            for: assets.indices.contains(fromIndex) ? assets[fromIndex] : nil,
            maxHeight: maxCenterHeight,
            minWidth: normalItemSize.width
        )
        let toCenterWidth = Self.calculateCenterItemWidth(
            for: assets.indices.contains(toIndex) ? assets[toIndex] : nil,
            maxHeight: maxCenterHeight,
            minWidth: normalItemSize.width
        )
        
        return range.map { index in
            let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            
            let fromIsCenter = index == fromIndex
            let toIsCenter = index == toIndex
            let fromSize: CGSize = fromIsCenter ? CGSize(width: fromCenterWidth, height: maxCenterHeight) : normalItemSize
            let toSize: CGSize = toIsCenter ? CGSize(width: toCenterWidth, height: maxCenterHeight) : normalItemSize
            
            let fromX = expandedItemX(for: index, centerIndex: fromIndex, centerWidth: fromCenterWidth)
            let toX = expandedItemX(for: index, centerIndex: toIndex, centerWidth: toCenterWidth)
            
            attr.frame = CGRect(
                x: fromX + (toX - fromX) * progress,
                y: (centerY - fromSize.height / 2) + ((centerY - toSize.height / 2) - (centerY - fromSize.height / 2)) * progress,
                width: fromSize.width + (toSize.width - fromSize.width) * progress,
                height: fromSize.height + (toSize.height - fromSize.height) * progress
            )
            attr.zIndex = max(
                fromIsCenter ? 1000 : max(1, 1000 - abs(index - fromIndex)),
                toIsCenter ? 1000 : max(1, 1000 - abs(index - toIndex))
            )
            return attr
        }
    }
    
    static func calculateCenterItemWidth(for asset: Asset?, maxHeight: CGFloat, minWidth: CGFloat) -> CGFloat {
        let aspectRatio = calculateAspectRatio(for: asset, defaultSize: CGSize(width: minWidth, height: maxHeight))
        return max(maxHeight * aspectRatio, minWidth)
    }
    
    static func calculateCollapsedCenterX(
        for index: Int,
        normalItemSize: CGSize
    ) -> CGFloat {
        CGFloat(index) * (normalItemSize.width + Constants.normalSpacing) + normalItemSize.width / 2
    }
    
    static func calculateExpandedCenterX(
        for index: Int,
        assets: [Asset],
        normalItemSize: CGSize,
        maxCenterHeight: CGFloat
    ) -> CGFloat {
        guard index >= 0 else { return normalItemSize.width / 2 }
        
        // 在 expanded 布局中，只有一个 center item 是特殊尺寸
        // 但此方法计算的是"如果 index 是 center"时的中心 x
        // 实际上这里 center 就是 index 本身（用于 calculateExpandedOffset）
        // 所以 items 0..<index 全是 normal, index 本身是 center
        let normalWidth = CGFloat(index) * normalItemSize.width
        let spacingBeforeCenter: CGFloat
        if index == 0 {
            spacingBeforeCenter = 0
        } else {
            // (index - 1) normalSpacing + 1 centerSpacing (right before center)
            spacingBeforeCenter = CGFloat(index - 1) * Constants.normalSpacing + Constants.centerSpacing
        }
        
        let centerWidth = calculateCenterItemWidth(
            for: assets.indices.contains(index) ? assets[index] : nil,
            maxHeight: maxCenterHeight,
            minWidth: normalItemSize.width
        )
        return normalWidth + spacingBeforeCenter + centerWidth / 2
    }
    
    static func calculateClosestExpandedIndex(
        to centerX: CGFloat,
        assets: [Asset],
        normalItemSize: CGSize,
        maxCenterHeight: CGFloat,
        itemCount: Int
    ) -> Int {
        guard itemCount > 0 else { return 0 }
        // 近似：expanded 布局中 center item 仅比 normal 略宽，用 normal stride 估算后微调
        let itemStride = normalItemSize.width + Constants.normalSpacing
        guard itemStride > 0 else { return 0 }
        let roughIndex = Int(round((centerX - normalItemSize.width / 2) / itemStride))
        let candidate = max(0, min(itemCount - 1, roughIndex))
        // 检查附近 ±2 个 item 精确距离
        let lo = max(0, candidate - 2)
        let hi = min(itemCount - 1, candidate + 2)
        var closestIndex = candidate
        var minDistance = CGFloat.greatestFiniteMagnitude
        for index in lo...hi {
            let itemCenterX = calculateExpandedCenterX(
                for: index,
                assets: assets,
                normalItemSize: normalItemSize,
                maxCenterHeight: maxCenterHeight
            )
            let distance = abs(itemCenterX - centerX)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        return closestIndex
    }
    
    static func calculateAspectRatio(for asset: Asset?, defaultSize: CGSize) -> CGFloat {
        guard let asset = asset else {
            return defaultSize.width / defaultSize.height
        }
        
        let phAsset = asset.phAsset
        let width = CGFloat(phAsset.pixelWidth)
        let height = CGFloat(phAsset.pixelHeight)
        if height > 0 {
            return width / height
        }
        
        let imageSize = asset.image.size
        if imageSize.height > 0 {
            return imageSize.width / imageSize.height
        }
        
        return defaultSize.width / defaultSize.height
    }
}

private final class ThumbnailCell: UICollectionViewCell {
    
    private var identifier: String = ""
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var selectedIndexBadgeView: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.clipsToBounds = true
        view.layer.cornerRadius = 7
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectedIndexBadgeView)
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectedIndexBadgeView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(2)
            maker.right.equalToSuperview().offset(-2)
            maker.width.height.equalTo(14)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        identifier = ""
        imageView.image = nil
    }
    
    func configure(with asset: Asset, options: PickerOptionsInfo?, manager: PickerManager?) {
        if let image = asset._images[.thumbnail] ?? asset._image {
            imageView.image = image
        } else {
            imageView.image = nil
            // Request thumbnail from PHImageManager if not yet loaded
            let id = asset.identifier
            identifier = id
            let fetchOptions = _PhotoFetchOptions(sizeMode: .thumbnail(100 * UIScreen.main.nativeScale), needCache: false)
            manager?.requestPhoto(for: asset.phAsset, options: fetchOptions) { [weak self] result in
                guard let self = self, self.identifier == id else { return }
                if case .success(let response) = result {
                    asset._images[.thumbnail] = response.image
                    self.imageView.image = response.image
                }
            }
        }
        
        if asset.isSelected {
            selectedIndexBadgeView.isHidden = false
            selectedIndexBadgeView.text = "\(asset.selectedNum)"
            selectedIndexBadgeView.backgroundColor = options?.theme[color: .primary]
        } else {
            selectedIndexBadgeView.isHidden = true
        }
    }
}
