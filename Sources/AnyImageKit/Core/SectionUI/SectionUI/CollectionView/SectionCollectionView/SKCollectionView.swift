// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

open class SKCollectionView: UICollectionView {
    
    public private(set) lazy var manager = SKCManager(sectionView: self)
    public private(set) lazy var registrationManager = SKCRegistrationManager(sectionView: self)

    public convenience init() {
        self.init(frame: .zero, collectionViewLayout: SKCollectionFlowLayout())
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewLayout = SKCollectionFlowLayout()
        initialize()
    }
}

public extension SKCollectionView {
    /// 滚动方向
    var scrollDirection: UICollectionView.ScrollDirection {
        set {
            switch collectionViewLayout {
            case let layout as UICollectionViewFlowLayout:
                layout.scrollDirection = newValue
            case let layout as UICollectionViewCompositionalLayout:
                layout.configuration.scrollDirection = newValue
            default:
                assertionFailure("未识别的 collectionViewLayout 类型")
            }
        }
        get {
            switch collectionViewLayout {
            case let layout as UICollectionViewFlowLayout:
                return layout.scrollDirection
            case let layout as UICollectionViewCompositionalLayout:
                return layout.configuration.scrollDirection
            default:
                assertionFailure("未识别的 collectionViewLayout 类型")
                return .vertical
            }
        }
    }
}

// MARK: - PluginModes
public extension SKCollectionView {
    /// 布局插件
    /// - Parameter pluginModes: 样式
    func set(pluginModes: [SKCollectionFlowLayout.PluginMode]) {
        (collectionViewLayout as? SKCollectionFlowLayout)?.pluginModes = pluginModes
    }
    
    /// 布局插件
    /// - Parameter pluginModes: 样式
    func set(pluginModes: SKCollectionFlowLayout.PluginMode...) {
        set(pluginModes: pluginModes)
    }
}

private extension SKCollectionView {
    func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        if backgroundColor == .black {
            backgroundColor = .white
        }
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
}

#endif
