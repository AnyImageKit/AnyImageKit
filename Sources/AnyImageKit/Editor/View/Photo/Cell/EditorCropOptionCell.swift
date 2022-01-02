//
//  EditorCropOptionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/5/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorCropOptionCell: UICollectionViewCell {
    
    private var option: EditorCropOption = .free
    private var selectColor: UIColor = .green
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectColor : .white
            setupLayer()
        }
    }
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .systemFont(ofSize: 8)
        view.textColor = .white
        view.textAlignment = .center
        view.minimumScaleFactor = 0.5
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    private var shapeLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

// MARK: - Public
extension EditorCropOptionCell {
    
    func set(_ options: EditorPhotoOptionsInfo, option: EditorCropOption, selectColor: UIColor) {
        self.option = option
        self.selectColor = selectColor
        
        setupLayer()
        switch option {
        case .free:
            label.text = options.theme[string: .editorFree]
        case .custom(let w, let h):
            label.text = "\(w):\(h)"
        }
        
        options.theme.labelConfiguration[.cropOption]?.configuration(label)
    }
}

// MARK: - Private
extension EditorCropOptionCell {
    
    private func setupLayer() {
        self.shapeLayer?.removeFromSuperlayer()
        self.shapeLayer = nil
        
        let size: CGFloat = 25
        let labelWidth: CGFloat
        let path = UIBezierPath()
        switch option {
        case .free:
            labelWidth = size
            let line: CGFloat = 8
            let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
            path.move(to: CGPoint(x: center.x-size/2, y: center.y-size/2+line))
            path.addLine(to: CGPoint(x: center.x-size/2, y: center.y-size/2))
            path.addLine(to: CGPoint(x: center.x-size/2+line, y: center.y-size/2))
            path.move(to: CGPoint(x: center.x+size/2-line, y: center.y-size/2))
            path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-size/2))
            path.addLine(to: CGPoint(x: center.x+size/2, y: center.y-size/2+line))
            path.move(to: CGPoint(x: center.x+size/2, y: center.y+size/2-line))
            path.addLine(to: CGPoint(x: center.x+size/2, y: center.y+size/2))
            path.addLine(to: CGPoint(x: center.x+size/2-line, y: center.y+size/2))
            path.move(to: CGPoint(x: center.x-size/2+line, y: center.y+size/2))
            path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+size/2))
            path.addLine(to: CGPoint(x: center.x-size/2, y: center.y+size/2-line))
        case .custom(let w, let h):
            let width: CGFloat
            let height: CGFloat
            if w >= h {
                width = size
                height = size * CGFloat(h) / CGFloat(w)
            } else {
                height = size
                width = size * CGFloat(w) / CGFloat(h)
            }
            labelWidth = width
            let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
            path.move(to: CGPoint(x: center.x-width/2, y: center.y-height/2))
            path.addLine(to: CGPoint(x: center.x+width/2, y: center.y-height/2))
            path.addLine(to: CGPoint(x: center.x+width/2, y: center.y+height/2))
            path.addLine(to: CGPoint(x: center.x-width/2, y: center.y+height/2))
            path.addLine(to: CGPoint(x: center.x-width/2, y: center.y-height/2))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.cornerRadius = 2
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = isSelected ? selectColor.cgColor : UIColor.white.cgColor
        layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
        
        label.snp.remakeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.width.equalTo(labelWidth-2)
        }
    }
}
