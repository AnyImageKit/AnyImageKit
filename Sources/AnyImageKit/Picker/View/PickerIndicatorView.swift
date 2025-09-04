//
//  PickerIndicatorView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/9/4.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PickerIndicatorView: UIView {
    
    var hideIndicatorCancellable: AnyCancellable?
    
    var inPan = false {
        didSet {
            didPan()
        }
    }
    
    private(set) lazy var indicatorImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.alpha = 0.4
        return view
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isUserInteractionEnabled = false
        view.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.textAlignment = .center
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        view.alpha = 0.0
        view.clipsToBounds = true
        return view
    }()
    private lazy var dateShadowView: UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        view.layer.applySketchShadow(color: .black, alpha: 0.2, x: 0, y: 4, blur: 8, spread: 0)
        return view
    }()
    
    private let formatter = DateFormatter()
    private let calendar = Calendar.current
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerIndicatorView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        self.isHidden = options.scrollIndicator == .none
        indicatorImageView.isHidden = options.scrollIndicator != .verticalBar
        dateLabel.isHidden = options.scrollIndicator != .horizontalBar
        indicatorImageView.image = options.theme[icon: .indicator]
        dateLabel.textColor = options.theme[color: .text].resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }
}

// MARK: - Public
extension PickerIndicatorView {
    
    public func update(_ first: Asset?, options: PickerOptionsInfo) {
        guard options.scrollIndicator == .horizontalBar else {
            return
        }
        guard let firstDate = first?.phAsset.creationDate else {
            return
        }
        let isThisYear = calendar.isDate(firstDate, equalTo: Date(), toGranularity: .year)
        formatter.dateFormat = options.theme[string: isThisYear ? .monthDayFormat : .fullDateFormat]
        dateLabel.text = formatter.string(from: firstDate)
        dateLabel.alpha = dateLabel.text?.isEmpty == true ? 0.0 : 1.0
        dateShadowView.isHidden = dateLabel.text?.isEmpty ?? true
        let dateWidth = dateLabel.intrinsicContentSize.width + CGFloat(10 * 2)
        dateShadowView.snp.updateConstraints { make in
            make.width.equalTo(dateWidth)
        }
    }
}

// MARK: - UI
extension PickerIndicatorView {
    
    private func setupView() {
        addSubview(indicatorImageView)
        addSubview(dateShadowView)
        dateShadowView.addSubview(dateLabel)
        
        indicatorImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
            make.width.equalTo(37)
            make.height.equalTo(55)
        }
        dateShadowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func didPan() {
        guard dateLabel.isHidden == false else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            self.dateShadowView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(self.inPan ? -68 : -8)
            }
            self.layoutIfNeeded()
        }
    }
}
