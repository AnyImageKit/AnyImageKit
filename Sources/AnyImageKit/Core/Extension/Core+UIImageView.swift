//
//  Core+UIImageView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/20.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImage(_ image: UIImage, animated: Bool) {
        self.image = image
        if animated {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(transition, forKey: nil)
        }
    }
}
