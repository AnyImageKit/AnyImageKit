//
//  Editor+CGSize.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/15.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

extension CGSize {
    
    func multipliedBy(_ amount: CGFloat) -> CGSize {
        guard amount != 1.0 else { return self }
        return CGSize(width: width * amount, height: height * amount)
    }
}
