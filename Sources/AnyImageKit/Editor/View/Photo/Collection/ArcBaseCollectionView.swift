//
//  ArcBaseCollectionView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/5.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

class ArcBaseCollectionView: UIView {
    
    enum ArcSelectdType {
        case index(Int)
        case present(CGFloat)
        
        var index: Int {
            switch self {
            case .index(let value):
                return value
            case .present(_):
                return 0
            }
        }
        
        var present: CGFloat {
            switch self {
            case .index(_):
                return 0
            case .present(let value):
                if value >= 1 {
                    return 1.0
                } else if value <= 0 {
                    return 0.0
                } else {
                    return value
                }
            }
        }
    }
    
    struct ArcOption {
        let size: CGSize
        let spacing: CGFloat
        let topMargin: CGFloat
        let bottomMargin: CGFloat
        let dotIndex: Int
        let selectedIndex: ArcSelectdType
    }
    
    let option: ArcOption
    let topMargin: CGFloat
    let bottomMargin: CGFloat
    
    var dotIndex: Int = 0
    var selectedIndex: ArcSelectdType = .index(0)
    
    var spacing: CGFloat = 2 {
        didSet {
            flowLayout.minimumLineSpacing = spacing
            flowLayout.minimumInteritemSpacing = spacing
        }
    }
    
    var size: CGSize = .init(width: 50, height: 50) {
        didSet {
            if isRegular {
                flowLayout.itemSize = .init(width: size.height + topMargin, height: size.width)
            } else {
                flowLayout.itemSize = .init(width: size.width, height: size.height + topMargin)
            }
        }
    }
    
    private(set) var preIsRegular: Bool = false
    
    private(set) var isRegular: Bool = true {
        didSet {
            preIsRegular = oldValue
            flowLayout.isRegular = isRegular
            if isRegular {
                flowLayout.itemSize = .init(width: size.height + topMargin, height: size.width)
            } else {
                flowLayout.itemSize = .init(width: size.width, height: size.height + topMargin)
            }
        }
    }
    
    private(set) lazy var flowLayout: ArcFlowLayout = {
        let layout = ArcFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .horizontal
        return layout
    }()
    private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private(set) lazy var centerView: UIView = UIView()
    private var centerViewSize: CGSize = .zero
    private var centerViewTopMargin: CGFloat = 0
    
    private lazy var shadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(1.0).cgColor,
            UIColor.white.withAlphaComponent(1.0).cgColor,
            UIColor.white.withAlphaComponent(1.0).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        layer.locations = [0, 0.15, 0.5, 0.85, 1.0]
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return layer
    }()
    
    init(option: ArcOption) {
        self.option = option
        self.size = option.size
        self.spacing = option.spacing
        self.topMargin = option.topMargin
        self.bottomMargin = option.bottomMargin
        self.dotIndex = option.dotIndex
        self.selectedIndex = option.selectedIndex
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowLayer.frame = bounds
        
        if isRegular {
            let margin = (frame.height - size.width) / 2
            flowLayout.sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: bottomMargin)
        } else {
            let margin = (frame.width - size.width) / 2
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: bottomMargin, right: margin)
        }
    }
    
    // MARK: - Public
    
    func updateLayout(isRegular: Bool) {
        self.isRegular = isRegular
        
        if isRegular {
            shadowLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            shadowLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            flowLayout.scrollDirection = .vertical
            collectionView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            shadowLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            shadowLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            flowLayout.scrollDirection = .horizontal
            collectionView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        collectionView.reloadData()
        layoutCenterView()
    }
    
    func setCenterView(_ centerView: UIView, size: CGSize, topMargin: CGFloat) {
        self.centerView.removeFromSuperview()
        self.centerView = centerView
        self.centerViewSize = size
        self.centerViewTopMargin = topMargin
        addSubview(centerView)
        layoutCenterView()
    }
    
    func set(dotIndex: Int, selectedIndex: ArcSelectdType) {
        self.dotIndex = dotIndex
        self.selectedIndex = selectedIndex
        collectionView.reloadData()
    }
}

// MARK: - UI
extension ArcBaseCollectionView {
    
    private func setupView() {
        layer.mask = shadowLayer
        addSubview(collectionView)
    }
    
    private func layoutCenterView() {
        guard centerView.superview != nil else { return }
        centerView.snp.remakeConstraints { make in
            if isRegular {
                make.leading.equalToSuperview().offset(centerViewTopMargin)
                make.centerY.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(centerViewTopMargin)
                make.centerX.equalToSuperview()
            }
            make.size.equalTo(centerViewSize.reversed(isRegular))
        }
    }
}
