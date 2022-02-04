//
//  ArcCollectionView.swift
//  AnyImageKit
//
//  Created by Ray on 2022/2/4.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ArcCollectionView: UIView {
    
    var spacing: CGFloat = 2 {
        didSet {
            flowLayout.minimumLineSpacing = spacing
            flowLayout.minimumInteritemSpacing = spacing
        }
    }
    
    var size: CGSize = .init(width: 50, height: 50) {
        didSet {
            if isRegular {
                flowLayout.itemSize = .init(width: size.width + topMargin, height: size.height)
            } else {
                flowLayout.itemSize = .init(width: size.width, height: size.height + topMargin)
            }
        }
    }
    
    var hiddenSideShadow: Bool = false {
        didSet {
            shadowLayer.isHidden = hiddenSideShadow
        }
    }
    
    let items: [UIView]
    let topMargin: CGFloat
    let bottomMargin: CGFloat
    
    private var isRegular: Bool = true {
        didSet {
            flowLayout.isRegular = isRegular
            if isRegular {
                flowLayout.itemSize = .init(width: size.width + topMargin, height: size.height)
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
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.registerCell(ArcCollectionCell.self)
        
        return view
    }()
    private lazy var centerView: UIView = UIView()
    private var centerViewSize: CGSize = .zero
    
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
    
    init(items: [UIView], size: CGSize, spacing: CGFloat, topMargin: CGFloat, bottomMargin: CGFloat) {
        self.items = items
        self.size = size
        self.spacing = spacing
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
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
            let margin = (frame.height - size.height) / 2
            flowLayout.sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
        } else {
            let margin = (frame.width - size.width) / 2
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        }
    }
}

// MARK: - Public
extension ArcCollectionView {
    
    func setCenterView(_ centerView: UIView, size: CGSize) {
        self.centerView.removeFromSuperview()
        self.centerView = centerView
        self.centerViewSize = size
        addSubview(centerView)
        layoutCenterView()
    }
    
    private func layoutCenterView() {
        guard centerView.superview != nil else { return }
        centerView.snp.remakeConstraints { make in
            if isRegular {
                make.centerX.equalToSuperview().offset((topMargin-bottomMargin)/2)
                make.centerY.equalToSuperview()
            } else {
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset((topMargin-bottomMargin)/2)
            }
            make.size.equalTo(size)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ArcCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select -> ", indexPath.row)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        // TODO: call
    }
}

// MARK: - UICollectionViewDataSource
extension ArcCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ArcCollectionCell.self, for: indexPath)
        cell.config(view: items[indexPath.row], size: size, isRegular: isRegular, hiddenDot: indexPath.row != 0)
//        cell.backgroundColor = .red
        return cell
    }
}

// MARK: - UI
extension ArcCollectionView {
    
    private func setupView() {
        layer.mask = shadowLayer
        addSubview(collectionView)
    }
    
    func updateLayout(isRegular: Bool) {
        self.isRegular = isRegular
        
        if isRegular {
            shadowLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            shadowLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            flowLayout.scrollDirection = .vertical
            collectionView.snp.remakeConstraints { make in
                if topMargin > 0 {
                    make.top.bottom.leading.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-bottomMargin)
                } else {
                    make.edges.equalToSuperview()
                }
            }
        } else {
            shadowLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            shadowLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            flowLayout.scrollDirection = .horizontal
            collectionView.snp.remakeConstraints { make in
                if topMargin > 0 {
                    make.top.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-bottomMargin)
                } else {
                    make.edges.equalToSuperview()
                }
            }
        }
        
        collectionView.reloadData()
        layoutCenterView()
    }
}

