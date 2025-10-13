//
//  SingleTypeHorizontalSection.swift
//  Passionate
//
//  Created by linhey on 2022/3/25.
//

#if canImport(UIKit)
import UIKit

public extension SKCSectionActionProtocol where Self: SKCDataSourceProtocol & SKCDelegateProtocol {
    
    func wrapperToHorizontalSection(_ model: SKCSectionViewCell.Model) -> SKCSingleTypeSection<SKCSectionViewCell> {
        SKCSectionViewCell.wrapperToSingleTypeSection(model)
    }
    
    func wrapperToHorizontalSection(_ model: [SKCSectionViewCell.Model]) -> SKCSingleTypeSection<SKCSectionViewCell> {
        SKCSectionViewCell.wrapperToSingleTypeSection(model)
    }
    
    func wrapperToHorizontalSection(height: CGFloat,
                                    insets: UIEdgeInsets = .zero,
                                    style: ((_ sectionView: SKCollectionView, _ section: Self) -> Void)? = nil) -> SKCSingleTypeSection<SKCSectionViewCell> {
        wrapperToHorizontalSection(.init(section: .normal([self]),
                                         height: height,
                                         insets: insets,
                                         scrollDirection: .horizontal,
                                         style: { [weak self] sectionView in
            guard let self = self else { return }
            style?(sectionView, self)
        }))
    }
    
    @available(*, deprecated, renamed: "wrapperToHorizontalSection", message: "调整命名")
    func wrapperToHorizontalSectionViewCell(height: CGFloat? = nil,
                                            insets: UIEdgeInsets = .zero,
                                            style: ((_ sectionView: SKCollectionView, _ section: Self) -> Void)? = nil) -> SKCSingleTypeSection<SKCSectionViewCell> {
        self.wrapperToHorizontalSection(height: height ?? .zero, insets: insets, style: style)
    }
    
}

public final class SKCSectionViewCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    public struct Model {
        
        public enum SectionType {
            case normal([any SKCBaseSectionProtocol])
        }
        
        public var section: SectionType
        public var insets: UIEdgeInsets
        public var size: (_ size: CGSize, _ model: Model) -> CGSize
        public var style: SKInout<SKCollectionView>?
        public var scrollDirection: UICollectionView.ScrollDirection
        
        public static func horizontal<Cell: SKLoadViewProtocol & SKConfigurableView,
                                      S: SKCSingleTypeSection<Cell>>(section: S,
                                                                     heightModel: Cell.Model? = nil,
                                                                     insets: UIEdgeInsets = .zero,
                                                                     style: SKInout<SKCollectionView>? = nil) -> Model {
            .init(section: .normal([section]),
                  insets: insets,
                  scrollDirection: .horizontal,
                  style: style,
                  size: { size, _ in
                var size = CGSize(width: size.width, height: Cell.preferredSize(limit: size, model: heightModel).height)
                size.height += insets.top + insets.bottom
                return size
            })
        }
        
        public init(section: SectionType,
                    insets: UIEdgeInsets = .zero,
                    scrollDirection: UICollectionView.ScrollDirection,
                    style: SKInout<SKCollectionView>? = nil,
                    size: @escaping (_ size: CGSize, _ model: Model) -> CGSize) {
            self.section = section
            self.insets = insets
            self.size = size
            self.style = style
            self.scrollDirection = scrollDirection
        }
        
        public init(section: SectionType,
                    height: CGFloat? = nil,
                    insets: UIEdgeInsets = .zero,
                    scrollDirection: UICollectionView.ScrollDirection,
                    style: ((_ sectionView: SKCollectionView) -> Void)? = nil) {
            self.init(section: section,
                      insets: insets,
                      scrollDirection: scrollDirection,
                      style: .set(style),
                      size: { size, model in
                return CGSize(width: size.width, height: (height ?? .zero) + model.insets.top + model.insets.bottom)
            })
        }
        
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        return model.size(size, model)
    }
    
    public func config(_ model: Model) {
        sectionView.scrollDirection = model.scrollDirection
        _ = model.style?.build(sectionView)
        edgeConstraint.apply(model.insets)
        switch model.section {
        case .normal(let list):
            sectionView.manager.reload(list)
        }
    }
    
    private struct EdgeConstraint {
        
        var all: [NSLayoutConstraint] { [top, left, right, bottom] }
        
        let top: NSLayoutConstraint
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        let bottom: NSLayoutConstraint
        
        init(_ view: UIView, superView: UIView) {
            top = view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0)
            left = view.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 0)
            right = view.rightAnchor.constraint(equalTo: superView.rightAnchor, constant: 0)
            bottom = view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0)
        }
        
        func apply(_ inset: UIEdgeInsets) {
            top.constant = inset.top
            left.constant = inset.left
            right.constant = -inset.right
            bottom.constant = -inset.bottom
        }
        
        func activate() {
            NSLayoutConstraint.activate(all)
        }
        
        func deactivate() {
            NSLayoutConstraint.deactivate(all)
        }
    }
    
    public private(set) lazy var sectionView = SKCollectionView()
    private lazy var edgeConstraint = EdgeConstraint(sectionView, superView: contentView)
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.backgroundColor = .clear
        contentView.addSubview(sectionView)
        sectionView.scrollDirection = .horizontal
        edgeConstraint.activate()
    }
}

#endif
