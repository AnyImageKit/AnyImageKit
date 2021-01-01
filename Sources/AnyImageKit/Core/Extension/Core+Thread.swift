//
//  Core+Thread.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Thread {
    
    static func runOnMain(_ task: @escaping () -> Void) {
        if Thread.isMainThread {
            task()
        } else {
            DispatchQueue.main.async {
                task()
            }
        }
    }
}
