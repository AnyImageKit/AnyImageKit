//
//  ThemeConfigable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/11/9.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public typealias ThemeConfigable = ThemeColorConfigable & ThemeIconConfigable & ThemeStringConfigable & ThemeLabelConfigable & ThemeButtonConfigable

public protocol ThemeColorConfigable {
    
    associatedtype ColorKey: Hashable
    
    subscript(color key: ColorKey) -> UIColor { get set }
}

public protocol ThemeIconConfigable {
    
    associatedtype IconKey: Hashable
    
    subscript(icon key: IconKey) -> UIImage? { get set }
}

public protocol ThemeStringConfigable {
    
    subscript(string key: StringConfigKey) -> String { get set }
}

public protocol ThemeLabelConfigable {
    
    associatedtype LabelKey: Hashable
    
    func configurationLabel(for key: LabelKey, configuration: @escaping ((UILabel) -> Void))
}

public protocol ThemeButtonConfigable {
    
    associatedtype ButtonKey: Hashable
    
    func configurationButton(for key: ButtonKey, configuration: @escaping ((UIButton) -> Void))
}
