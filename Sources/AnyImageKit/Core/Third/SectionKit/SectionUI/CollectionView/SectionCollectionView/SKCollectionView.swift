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
import Combine

open class SKCollectionView: UICollectionView, SKCRequestViewProtocol {
    
    public var requestPublishers: SKRequestPublishers = .init()
    public private(set) lazy var manager = SKCManager(sectionView: self)
    
    public var collectionViewFlowLayout: UICollectionViewFlowLayout? { collectionViewLayout as? UICollectionViewFlowLayout }
    private var pluginsModes: [SKCLayoutPlugins.Mode] = []
    private var registeredCellIdentifiers: [String: AnyClass] = [:]
    
    public convenience init() {
        let layout = SKCollectionFlowLayout()
        self.init(frame: .zero, collectionViewLayout: layout)
        self.initialize(layout: layout)
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        let layout = SKCollectionFlowLayout()
        collectionViewLayout = layout
        initialize()
        initialize(layout: layout)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        requestPublishers.layoutSubviews.send()
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
    
    func collectSectionLayoutPlugins() -> [SKCLayoutPlugins.Mode] {
        manager.sections
            .compactMap({ $0 as? (SKCSectionLayoutPluginProtocol & SKCSectionActionProtocol) })
            .map({ section in
                section.plugins.compactMap { plugin in
                    plugin.convert(section)
                }
            })
            .flatMap({ $0 })
    }
    /// 布局插件
    /// - Parameter pluginModes: 样式
    func set(pluginModes: [SKCLayoutPlugins.Mode]) {
        self.pluginsModes = pluginModes
    }
    
    /// 布局插件
    /// - Parameter pluginModes: 样式
    func set(pluginModes: SKCLayoutPlugins.Mode...) {
        set(pluginModes: pluginModes)
    }
}

private extension SKCollectionView {
    
    func initialize(layout: SKCollectionFlowLayout) {
        self.manager.flowLayoutForward.add(ui: layout)
        layout.fetchPlugins = { [weak self] in
            guard let self = self else { return .init(modes: []) }
            return .init(modes: pluginsModes + self.collectSectionLayoutPlugins())
        }
    }
    
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
