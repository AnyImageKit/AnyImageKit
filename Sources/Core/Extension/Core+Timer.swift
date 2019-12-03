//
//  Core+Timer.swift
//  AnyImageKit
//
//  Created by RoyLei on 12/3/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

final class Block <T> {
  let f : T
  init(_ f: T) { self.f = f }
}

extension Timer {
    @discardableResult
    open class func ly_scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        }
        return Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(ly_timerAction(_:)), userInfo: Block(block), repeats: repeats)
    }

    @objc class func ly_timerAction(_ sender: Timer) {
        if let block = sender.userInfo as? Block<(Timer) -> Swift.Void> {
            block.f(sender)
        }
    }
}
