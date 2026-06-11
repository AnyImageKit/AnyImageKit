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
    
}
 
// MARK: - PickerOptionsConfigurable
extension NumberCircleLGButton: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        guard #available(iOS 26.0, *) else {
            return
        }
        
        updateChildrenConfigurable(options: options)
        
        a11ySelectPhoto = options.theme[string: .pickerSelectPhoto]
        a11yUnselectPhoto = options.theme[string: .pickerUnselectPhoto]
        accessibilityLabel = isSelected ? a11yUnselectPhoto : a11ySelectPhoto
        
        configurationUpdateHandler = { button in
            var config = button.configuration
            
            if button.isSelected {
                config?.image = nil
                config?.background.backgroundColor = options.theme[color: .primary]
                config?.attributedTitle = AttributedString(self.number.description, attributes: AttributeContainer([
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 18)
                ]))
            } else {
                config?.image = UIImage.init(systemName: "checkmark")
                config?.background.backgroundColor = .clear
                config?.attributedTitle = nil
            }
            
            button.configuration = config
        }
    }
}

extension NumberCircleLGButton {
    
    func setNum(_ num: Int, isSelected: Bool, animated: Bool) {
        number = num
        self.isSelected = isSelected
        if #available(iOS 26.0, *) {
            setNeedsUpdateConfiguration()
            updateConfiguration()
        }
        accessibilityLabel = isSelected ? a11yUnselectPhoto : a11ySelectPhoto
    }
}
