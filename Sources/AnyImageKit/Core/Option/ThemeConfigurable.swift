//
//  ThemeConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/11/9.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public typealias ThemeConfigurable = ThemeColorConfigurable & ThemeIconConfigurable & ThemeStringConfigurable & ThemeLabelConfigurable & ThemeButtonConfigurable

public protocol ThemeColorConfigurable {
    
    associatedtype ColorKey: Hashable
    
    subscript(color key: ColorKey) -> UIColor { get set }
}

public protocol ThemeIconConfigurable {
    
    associatedtype IconKey: Hashable
    
    subscript(icon key: IconKey) -> UIImage? { get set }
}

public protocol ThemeStringConfigurable {
    
    subscript(string key: StringConfigKey) -> String { get set }
}

public protocol ThemeLabelConfigurable {
    
    associatedtype LabelKey: Hashable
    
    func configurationLabel(for key: LabelKey, configuration: @escaping ((UILabel) -> Void))
}

public protocol ThemeButtonConfigurable {
    
    associatedtype ButtonKey: Hashable
    
    func configurationButton(for key: ButtonKey, configuration: @escaping ((UIButton) -> Void))
}
