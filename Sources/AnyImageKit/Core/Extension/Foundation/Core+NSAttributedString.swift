//
//  Core+NSAttributedString.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    /// 文本行数
    ///
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 最大宽度
    /// - Returns: 行数
    func rows(maxWidth width: CGFloat, lineHeight: CGFloat? = nil) -> Int {
        // 获取单行时候的内容的高度
        var lineHeight = lineHeight

        if lineHeight == nil {
            lineHeight = self.size().height
        }

        guard let singleLineHeight = lineHeight, singleLineHeight > 0 else {
            return 0
        }

        // 获取多行时候,文字的size
        let textSize = self.size(maxWidth: width)

        // 返回计算的行数
        return Int(ceil(textSize.height / singleLineHeight))
    }

    /// 获取字符串的CGSize
    ///
    /// - Parameters:
    ///   - font: 字体大小
    ///   - size: 字符串长宽限制
    /// - Returns: 字符串的Bounds
    func size(maxWidth width: CGFloat = CGFloat.greatestFiniteMagnitude,
              maxHeight height: CGFloat = CGFloat.greatestFiniteMagnitude,
              option: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]) -> CGSize {
        return self.bounds(size: CGSize(width: width, height: height), option: option).size
    }

    /// 获取字符串的Bounds
    ///
    /// - Parameters:
    ///   - font: 字体大小
    ///   - size: 字符串长宽限制
    /// - Returns: 字符串的Bounds
    func bounds(size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                      height: CGFloat.greatestFiniteMagnitude),
                option: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]) -> CGRect {

        guard length != 0 else {
            return CGRect.zero
        }
        
        return boundingRect(with: size, options: option, context: nil)
    }
}
