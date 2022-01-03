//
//  Ex+XCUIElement.swift
//  AnyImageKitUITests
//
//  Created by 蒋惠 on 2020/1/3.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import XCTest

extension XCUIElement {
    
    func tapIfElementExists() {
        if exists {
            tap()
        }
    }
    
    func tapAfter(_ time: TimeInterval) {
        sleep(time)
        tap()
    }
}
