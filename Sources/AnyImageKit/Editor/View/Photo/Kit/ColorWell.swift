//
//  ColorWell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/8/19.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

@available(iOS 14, *)
final class ColorWell: UIControl {
    
    /// Title for the color picker.
    ///
    /// Should explain what kind of color to pick. Example values are "Stroke Color" or "Fill Color".
    var title: String? = nil

    
    /// Controls whether alpha is supported or not.
    ///
    /// If set to `NO` users are only able to pick fully opaque colors.
    var supportsAlpha: Bool = false

    
    /// Sets the selected color on the color picker and is updated when the user changes the selection.
    /// Does support KVO and does send `UIControlEventValueChanged`.
    var selectedColor: UIColor? = nil {
        didSet {
            colorView.isHidden = selectedColor == nil
            colorView.backgroundColor = selectedColor
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = BundleHelper.image(named: "ColorWell", module: .editor)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.cgColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(colorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = bounds.width
        let colorSize = 20 / 24 * imageSize
        imageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        colorView.frame = CGRect(x: 0, y: 0, width: colorSize, height: colorSize)
        imageView.center = convert(center, from: superview)
        colorView.center = convert(center, from: superview)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let inside = bounds.contains(touch.location(in: self))
        if inside {
            sendActions(for: .touchUpInside)
            presentColorPicker()
        } else {
            sendActions(for: .touchUpOutside)
        }
    }
    
    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.title = title
        picker.supportsAlpha = supportsAlpha
        if let selectedColor = selectedColor {
            picker.selectedColor = selectedColor
        }
        if let controller = getController() {
            controller.present(picker, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIColorPickerViewControllerDelegate
@available(iOS 14, *)
extension ColorWell: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        sendActions(for: .valueChanged)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
    }
}
