//
//  NumberCircleLGButton.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/11/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final class NumberCircleLGButton: UIButton {
    
    private var a11ySelectPhoto: String = BundleHelper.localizedString(key: "SELECT_PHOTO", module: .picker)
    private var a11yUnselectPhoto: String = BundleHelper.localizedString(key: "UNSELECT_PHOTO", module: .picker)
    
    private var number = 0
    private var options: PickerOptionsInfo?
    
}
 
// MARK: - PickerOptionsConfigurable
extension NumberCircleLGButton: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        guard #available(iOS 26.0, *) else {
            return
        }
        
        self.options = options
        updateChildrenConfigurable(options: options)
        
        a11ySelectPhoto = options.theme[string: .pickerSelectPhoto]
        a11yUnselectPhoto = options.theme[string: .pickerUnselectPhoto]
        accessibilityLabel = isSelected ? a11yUnselectPhoto : a11ySelectPhoto
        
        configurationUpdateHandler = { [weak self] button in
            self?.applySelectConfiguration(to: button)
        }
        applySelectConfiguration(to: self)
        setNeedsUpdateConfiguration()
    }
    
    @available(iOS 26.0, *)
    private func applySelectConfiguration(to button: UIButton) {
        guard let options else { return }
        var config = button.configuration
        
        if button.isSelected {
            config?.image = nil
            config?.background.backgroundColor = options.theme[color: .primary]
            config?.attributedTitle = AttributedString(number.description, attributes: AttributeContainer([
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 18)
            ]))
        } else {
            config?.image = UIImage(systemName: "checkmark")
            config?.background.backgroundColor = .clear
            config?.attributedTitle = nil
        }
        
        button.configuration = config
        options.theme.applyGlassButtonConfiguration(.select, to: button)
    }
}

extension NumberCircleLGButton {
    
    func setNum(_ num: Int, isSelected: Bool, animated: Bool) {
        number = num
        self.isSelected = isSelected
        accessibilityLabel = isSelected ? a11yUnselectPhoto : a11ySelectPhoto
        if #available(iOS 26.0, *) {
            applySelectConfiguration(to: self)
            setNeedsUpdateConfiguration()
        }
    }
}
