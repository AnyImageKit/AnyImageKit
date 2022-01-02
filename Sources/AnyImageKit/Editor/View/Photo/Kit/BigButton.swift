//
//  BigButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/5/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class BigButton: UIButton {
    
    let moreInsets: UIEdgeInsets
    
    init(moreInsets: UIEdgeInsets = .zero) {
        self.moreInsets = moreInsets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var frame = self.bounds
        frame.origin.x -= moreInsets.left
        frame.origin.y -= moreInsets.top
        frame.size.width += (moreInsets.left + moreInsets.right)
        frame.size.height += (moreInsets.top + moreInsets.bottom)
        return bounds.contains(point)
    }
}
