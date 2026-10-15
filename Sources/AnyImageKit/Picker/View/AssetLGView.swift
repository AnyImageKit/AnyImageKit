//
//  AssetLGView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/10/21.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AssetLGView: UIView {
    
    let toolBar = UIView()
    var closeButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    let filterBarContainer = UIView()
    private var albumTitle: String?
    private var options: PickerOptionsInfo?
    private var didCollapseLimitedButton = false
    
    private(set) lazy var previewButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "photo.badge.checkmark")
        view.configuration = config
        view.isEnabled = false
        return view
    }()
    
    private(set) lazy var moreButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "line.3.horizontal.decrease")
        view.configuration = config
        view.showsMenuAsPrimaryAction = true
        return view
    }()
    
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
    
    func setAlbumTitle(_ title: String) {
        albumTitle = title
        refreshAlbumButton()
    }
    
    func collapseLimitedButtonTitle() {
        guard #available(iOS 26.0, *), options?.designRequiresCompatibility != true else { return }
        didCollapseLimitedButton = true
        if let options {
            options.theme.applyGlassButtonConfiguration(.limitedPermission, to: limitedButton)
        }
        var config = limitedButton.configuration
        config?.title = nil
        limitedButton.configuration = config
    }
    
    private func setupFilterBarContainer() {
        filterBarContainer.backgroundColor = .clear
    }
}

extension AssetLGView: PickerOptionsConfigurable {

    func update(options: PickerOptionsInfo) {
        self.options = options
        refreshAlbumButton()
        refreshLimitedButton()
        updateChildrenConfigurable(options: options)
    }
    
    private func refreshAlbumButton() {
        let title = albumTitle ?? options?.theme[string: .pickerRecentAlbumTitle] ?? BundleHelper.localizedString(key: "RECENT_ALBUM_TITLE", module: .picker)
        let accessibilityFormat = options?.theme[string: .pickerA11ySwitchAlbumTips] ?? BundleHelper.localizedString(key: "A11Y_SWITCH_ALBUM_TIPS", module: .picker)
        let accessibilityLabel = String(format: accessibilityFormat, title)
        if #available(iOS 26.0, *), options?.designRequiresCompatibility != true {
            let menu = albumButton.menu
            options?.theme.applyGlassButtonConfiguration(.album, to: albumButton)
            albumButton.menu = menu
            albumButton.showsMenuAsPrimaryAction = true
            var config = albumButton.configuration
            config?.title = title
            albumButton.configuration = config
            albumButton.accessibilityLabel = accessibilityLabel
        } else {
            albumButton.setTitle(title, for: .normal)
            albumButton.accessibilityLabel = accessibilityLabel
        }
    }
    
    private func refreshLimitedButton() {
        let title = options?.theme[string: .pickerLimitedPhotosPermissionButtonTitle] ?? BundleHelper.localizedString(key: "LIMITED_PHOTOS_PERMISSION_BUTTON_TITLE", module: .picker)
        if #available(iOS 26.0, *), options?.designRequiresCompatibility != true {
            limitedButton.accessibilityLabel = title
            options?.theme.applyGlassButtonConfiguration(.limitedPermission, to: limitedButton)
            var config = limitedButton.configuration
            config?.title = didCollapseLimitedButton ? nil : title
            limitedButton.configuration = config
        } else {
            limitedButton.setTitle(title, for: .normal)
            limitedButton.accessibilityLabel = title
        }
    }
}
