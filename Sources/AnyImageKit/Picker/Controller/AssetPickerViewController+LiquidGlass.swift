//
//  AssetPickerViewController+LiquidGlass.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/10/21.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

private struct LGScrollAnchor {
    let indexPath: IndexPath
    let relativePositionInCell: CGFloat
    let viewportAnchorY: CGFloat
}

extension AssetPickerViewController {
    
    func lgSetupNavigation() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        
        lgView.closeButton = UIBarButtonItem(image: manager.options.theme[icon: .closeButton], landscapeImagePhone: nil, style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.leftBarButtonItem = lgView.closeButton
        
        lgView.doneButton = UIBarButtonItem(image: manager.options.theme[icon: .doneButton], landscapeImagePhone: nil, style: .prominent, target: self, action: #selector(lgDoneButtonTapped(_:)))
        lgView.doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = lgView.doneButton
        
        navigationItem.titleView = lgView.albumButton
        lgUpdateBarButtonAppearance(options: manager.options)
    }
    
    func lgSetupAlbumMenu() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        
        let children: [UIMenuElement] = albums.map { album in
            return UIAction(title: "\(album.title) (\(album.count.description))", image: nil, state: self.album == album ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                self.setAlbum(album)
                if album.filter == self.filterBar.selectedType,
                   album.displaySort == self.currentAlbumDisplaySort {
                    self.reloadData(animated: false)
                    self.scrollToEnd()
                } else {
                    self.reloadAlbumForCurrentDisplay()
                }
                self.lgSetupAlbumMenu()
                self.lgView.setAlbumTitle(album.title)
            }
        }
        
        lgView.albumButton.menu = UIMenu(title: "", children: children)
    }
    
}

extension AssetPickerViewController {
    
    func lgSetupToolBar() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        
        lgView.filterBarContainer.isHidden = !showsMediaTypeFilterBar
        if showsMediaTypeFilterBar {
            filterBar.update(options: manager.options)
            if filterBar.superview !== lgView.filterBarContainer {
                lgView.filterBarContainer.addSubview(filterBar)
                filterBar.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        } else {
            filterBar.removeFromSuperview()
        }
        
        view.addSubview(lgView.toolBar)
        lgView.toolBar.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        lgView.limitedButton.addTarget(self, action: #selector(limitedButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(lgView.limitedButton)
        lgView.limitedButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(lgView.toolBar.snp.top).offset(-16)
            make.height.equalTo(48)
        }
        
        lgSetupToolBarMenu()
    }
    
    func lgSetupToolBarMenu() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        
        lgView.previewButton = UIBarButtonItem(image: manager.options.theme[icon: .previewButton], landscapeImagePhone: nil, style: .plain, target: self, action: #selector(previewButtonTapped))
        lgView.previewButton.isEnabled = false
        lgView.previewButton.width = 44
        lgView.moreButton = UIBarButtonItem(image: manager.options.theme[icon: .moreButton], primaryAction: nil, menu: makeLGToolBarMenu())
        lgView.moreButton.width = 44
        lgUpdateBarButtonAppearance(options: manager.options)
        if showsMediaTypeFilterBar {
            let leadingSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            leadingSpace.width = 8
            let trailingSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            trailingSpace.width = 8
            
            lgView.toolBar.items = [
                lgView.previewButton,
                leadingSpace,
                UIBarButtonItem(customView: lgView.filterBarContainer),
                trailingSpace,
                lgView.moreButton
            ]
        } else {
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            lgView.toolBar.items = [
                lgView.previewButton,
                flexibleSpace,
                lgView.moreButton
            ]
        }
        
        lgUpdateToolBarLayout()
    }
    
    func updateLimitedButton() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        guard lgView.limitedButton.frame.width > 48, didAppear else { return }
        UIView.animate(withDuration: 0.25) {
            self.lgView.limitedButton.configuration?.title = nil
            self.lgView.limitedButton.snp.remakeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.bottom.equalTo(self.lgView.toolBar.snp.top).offset(-16)
                make.width.height.equalTo(48)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func lgUpdateBarButtonAppearance(options: PickerOptionsInfo) {
        guard #available(iOS 26.0, *), !options.designRequiresCompatibility else { return }

        lgView.closeButton.image = options.theme[icon: .closeButton]
        lgView.closeButton.accessibilityLabel = options.theme[string: .cancel]

        lgView.doneButton.image = options.theme[icon: .doneButton]
        lgView.doneButton.tintColor = options.theme[color: .primary]
        lgView.doneButton.accessibilityLabel = options.theme[string: .done]

        lgView.previewButton.image = options.theme[icon: .previewButton]
        lgView.previewButton.accessibilityLabel = options.theme[string: .preview]

        lgView.moreButton.image = options.theme[icon: .moreButton]
        lgView.moreButton.accessibilityLabel = options.theme[string: .pickerMoreOptions]
    }

    private func makeLGToolBarMenu() -> UIMenu {
        let columnLevels = lgColumnNumberLevels
        let currentLevelIndex = lgCurrentColumnLevelIndex(in: columnLevels)
        let canZoomIn = currentLevelIndex > 0
        let canZoomOut = currentLevelIndex < columnLevels.count - 1
        
        var children: [UIMenuElement] = []
        
        if manager.options.allowUseOriginalImage {
            children.append(UIAction(title: manager.options.theme[string: .pickerOriginalImage],
                                     image: UIImage(systemName: manager.useOriginalImage ? "checkmark.circle" : "circle"),
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: lgMenuActionAttributes(enabled: true),
                                     state: .off) { [weak self] _ in
                self?.toggleLGOriginalImage()
            })
        }
        
        children.append(
            UIMenu(title: manager.options.theme[string: .pickerDisplayOptions], options: .displayInline, children: [
                UIAction(title: manager.options.theme[string: .pickerZoomIn],
                         image: UIImage(systemName: "plus.magnifyingglass"),
                         identifier: nil,
                         discoverabilityTitle: nil,
                         attributes: lgMenuActionAttributes(enabled: canZoomIn),
                         state: .off) { [weak self] _ in
                    self?.changeLGColumnNumber(by: -1)
                },
                UIAction(title: manager.options.theme[string: .pickerZoomOut],
                         image: UIImage(systemName: "minus.magnifyingglass"),
                         identifier: nil,
                         discoverabilityTitle: nil,
                         attributes: lgMenuActionAttributes(enabled: canZoomOut),
                         state: .off) { [weak self] _ in
                    self?.changeLGColumnNumber(by: 1)
                }
            ])
        )

        children.append(
            UIMenu(title: "", options: .displayInline, children: [
                UIAction(title: manager.options.theme[string: .pickerSortByDateCaptured],
                         state: lgAssetSortOption == .capturedDate ? .on : .off) { [weak self] _ in
                    self?.changeLGAssetSortOption(.capturedDate)
                },
                UIAction(title: manager.options.theme[string: .pickerSortByRecentlyAdded],
                         state: lgAssetSortOption == .recentlyAdded ? .on : .off) { [weak self] _ in
                    self?.changeLGAssetSortOption(.recentlyAdded)
                }
            ])
        )
        
        return UIMenu(title: "", children: children)
    }
    
    private var lgColumnNumberLevels: [Int] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let availableWidth = max(view.bounds.width, ScreenHelper.mainBounds.width)
            let widthBasedMax = max(3, Int(availableWidth / 135))
            return Array(3...min(8, widthBasedMax))
        }
        return [3, 4, 5]
    }
    
    private func lgCurrentColumnLevelIndex(in levels: [Int]) -> Int {
        let currentColumnCount = lgCurrentDisplayedColumnCount()
        guard let index = levels.firstIndex(of: currentColumnCount) else {
            return levels.enumerated().min(by: { abs($0.element - currentColumnCount) < abs($1.element - currentColumnCount) })?.offset ?? 0
        }
        return index
    }
    
    private func lgCurrentDisplayedColumnCount() -> Int {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        guard let indexPath = visibleIndexPaths.first,
              let frame = collectionView.layoutAttributesForItem(at: indexPath)?.frame,
              frame.width > 0 else {
            return manager.options.columnNumber
        }
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let spacing = section.minimumInteritemSpacing
        let count = Int(round((availableWidth + spacing) / (frame.width + spacing)))
        return max(1, count)
    }
    
    private func toggleLGOriginalImage() {
        manager.useOriginalImage.toggle()
        trackObserver?.track(event: .pickerOriginalImage,
                             userInfo: [.isOn: manager.useOriginalImage, .page: AnyImagePage.pickerAsset])
        refreshLGMoreMenu()
    }
    
    private func changeLGColumnNumber(by delta: Int) {
        let columnLevels = lgColumnNumberLevels
        let currentLevelIndex = lgCurrentColumnLevelIndex(in: columnLevels)
        let newIndex = min(max(currentLevelIndex + delta, 0), columnLevels.count - 1)
        let newValue = columnLevels[newIndex]
        guard newValue != manager.options.columnNumber else { return }
        
        let scrollAnchor = captureLGScrollAnchor()
        
        manager.options.autoCalculateColumnNumber = false
        manager.options.columnNumber = newValue
        lgReloadDataWithoutScrolling()
        restoreLGScrollAnchor(scrollAnchor)
        refreshLGMoreMenu()
    }
    
    private func lgReloadDataWithoutScrolling() {
        collectionView.isUserInteractionEnabled = false
        UIView.performWithoutAnimation {
            section.config(album: album, columnCount: manager.options.columnNumber)
            collectionView.manager.reload(section)
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
        }
        collectionView.isUserInteractionEnabled = true
        
        if manager.options.scrollIndicator != .none && section.itemCount <= 50 {
            indicatorView.isHidden = true
        }
    }
    
    private func changeLGAssetSortOption(_ option: LGAssetSortOption) {
        guard option != lgAssetSortOption else { return }
        lgAssetSortOption = option
        reloadAlbumForCurrentDisplay()
        refreshLGMoreMenu()
    }
    
    private func captureLGScrollAnchor() -> LGScrollAnchor? {
        let minOffsetY = -collectionView.adjustedContentInset.top
        let maxOffsetY = max(minOffsetY, collectionView.contentSize.height - collectionView.bounds.height + collectionView.adjustedContentInset.bottom)
        let epsilon: CGFloat = 2
        
        let viewportAnchorY: CGFloat
        if collectionView.contentOffset.y <= minOffsetY + epsilon {
            viewportAnchorY = collectionView.adjustedContentInset.top + 1
        } else if collectionView.contentOffset.y >= maxOffsetY - epsilon {
            viewportAnchorY = collectionView.bounds.height - collectionView.adjustedContentInset.bottom - 1
        } else {
            viewportAnchorY = collectionView.adjustedContentInset.top + (collectionView.bounds.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom) / 2
        }
        
        let contentAnchorY = collectionView.contentOffset.y + viewportAnchorY
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        guard !visibleIndexPaths.isEmpty else { return nil }
        
        let anchorIndexPath = visibleIndexPaths.min { lhs, rhs in
            guard let lhsFrame = collectionView.layoutAttributesForItem(at: lhs)?.frame,
                  let rhsFrame = collectionView.layoutAttributesForItem(at: rhs)?.frame else {
                return false
            }
            return abs(lhsFrame.midY - contentAnchorY) < abs(rhsFrame.midY - contentAnchorY)
        } ?? visibleIndexPaths[0]
        
        guard let frame = collectionView.layoutAttributesForItem(at: anchorIndexPath)?.frame,
              frame.height > 0 else {
            return nil
        }
        
        let relativePosition = min(max((contentAnchorY - frame.minY) / frame.height, 0), 1)
        return LGScrollAnchor(indexPath: anchorIndexPath,
                              relativePositionInCell: relativePosition,
                              viewportAnchorY: viewportAnchorY)
    }
    
    private func restoreLGScrollAnchor(_ anchor: LGScrollAnchor?) {
        guard let anchor else { return }
        
        collectionView.layoutIfNeeded()
        
        guard anchor.indexPath.section < collectionView.numberOfSections,
              anchor.indexPath.item < collectionView.numberOfItems(inSection: anchor.indexPath.section),
              let frame = collectionView.layoutAttributesForItem(at: anchor.indexPath)?.frame else {
            return
        }
        
        let targetOffsetY = frame.minY + frame.height * anchor.relativePositionInCell - anchor.viewportAnchorY
        let minOffsetY = -collectionView.adjustedContentInset.top
        let maxOffsetY = max(minOffsetY, collectionView.contentSize.height - collectionView.bounds.height + collectionView.adjustedContentInset.bottom)
        let clampedOffsetY = min(max(targetOffsetY, minOffsetY), maxOffsetY)
        
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: clampedOffsetY), animated: false)
    }
    
    func lgUpdateToolBarLayout() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        guard showsMediaTypeFilterBar else { return }
        let horizontalMargins = lgView.toolBar.layoutMargins.left + lgView.toolBar.layoutMargins.right
        let buttonReservedWidth: CGFloat = 72
        let availableWidth = lgView.toolBar.bounds.width - horizontalMargins - buttonReservedWidth - buttonReservedWidth - 8 - 8
        lgView.updateFilterBarWidth(availableWidth)
    }
    
    private func refreshLGMoreMenu() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        lgView.moreButton.menu = makeLGToolBarMenu()
    }
    
    private func lgMenuActionAttributes(enabled: Bool) -> UIMenuElement.Attributes {
        if #available(iOS 16.0, *) {
            return enabled ? [.keepsMenuPresented] : [.disabled]
        }
        return enabled ? [] : [.disabled]
    }
}
