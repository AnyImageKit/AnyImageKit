//
//  AssetLGView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/10/21.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AssetLGView: UIView {
    
    let toolBar = UIToolbar()
    var closeButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    var previewButton = UIBarButtonItem()
    var moreButton = UIBarButtonItem()
    let filterBarContainer = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
    private var filterBarWidthConstraint: NSLayoutConstraint?
    private var albumTitle: String?
    
    private(set) lazy var albumButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        var config = UIButton.Configuration.clearGlass()
        config.title = BundleHelper.localizedString(key: "RECENT_ALBUM_TITLE", module: .picker)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = .init(pointSize: 12, weight: .medium)
        view.configuration = config
        view.accessibilityLabel = String(format: BundleHelper.localizedString(key: "A11Y_SWITCH_ALBUM_TIPS", module: .picker), config.title ?? "")
        view.showsMenuAsPrimaryAction = true
        return view
    }()
    
    private(set) lazy var limitedButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        view.isHidden = true
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "exclamationmark.triangle.fill")
        config.title = BundleHelper.localizedString(key: "LIMITED_PHOTOS_PERMISSION_BUTTON_TITLE", module: .picker)
        view.configuration = config
        view.accessibilityLabel = config.title
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFilterBarContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFilterBarWidth(_ width: CGFloat) {
        let finalWidth = max(width, 120)
        filterBarContainer.frame.size = CGSize(width: finalWidth, height: 48)
        filterBarWidthConstraint?.constant = finalWidth
        filterBarContainer.layoutIfNeeded()
    }
    
    func setAlbumTitle(_ title: String) {
        albumTitle = title
        albumButton.accessibilityLabel = String(format: BundleHelper.localizedString(key: "A11Y_SWITCH_ALBUM_TIPS", module: .picker), title)
        if #available(iOS 26.0, *) {
            albumButton.configuration?.title = title
        } else {
            albumButton.setTitle(title, for: .normal)
        }
    }

    private func setupFilterBarContainer() {
        filterBarContainer.backgroundColor = .clear
        filterBarContainer.translatesAutoresizingMaskIntoConstraints = false
        filterBarWidthConstraint = filterBarContainer.widthAnchor.constraint(equalToConstant: 200)
        filterBarWidthConstraint?.isActive = true
        filterBarContainer.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}

extension AssetLGView: PickerOptionsConfigurable {

    func update(options: PickerOptionsInfo) {
        let currentAlbumTitle = albumTitle ?? options.theme[string: .pickerRecentAlbumTitle]
        let albumAccessibilityLabel = String(format: options.theme[string: .pickerA11ySwitchAlbumTips], currentAlbumTitle)
        let limitedTitle = options.theme[string: .pickerLimitedPhotosPermissionButtonTitle]
        if #available(iOS 26.0, *) {
            albumButton.configuration?.title = currentAlbumTitle
            albumButton.accessibilityLabel = albumAccessibilityLabel
            limitedButton.configuration?.title = limitedTitle
        } else {
            albumButton.setTitle(currentAlbumTitle, for: .normal)
            albumButton.accessibilityLabel = albumAccessibilityLabel
            limitedButton.setTitle(limitedTitle, for: .normal)
        }
        limitedButton.accessibilityLabel = limitedTitle
        updateChildrenConfigurable(options: options)
    }
}
