//
//  PickerFilterBar.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/20.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Kingfisher

final class PickerFilterBar: UIView {
    
    private(set) var selectedType: PickerMediaTypeFilter = .all
    let selectEvent: Delegate<PickerMediaTypeFilter, Void> = .init()
    
    private var currentOptions: [PickerMediaTypeFilter] = []
    private var buttons: [UIButton] = []
    
    private lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.axis = .horizontal
        view.spacing = 0
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var indicator: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 2
        return view
    }()
    
    private(set) lazy var segmentedControl: UISegmentedControl = {
        guard #available(iOS 26.0, *) else {
            return UISegmentedControl(items: [])
        }
        let view = UISegmentedControl(frame: .zero, actions: [])
        view.selectedSegmentIndex = 0
        return view
    }()
    private(set) var segmentedActions: [UIAction] = []
    
    private var isFirst = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Action
extension PickerFilterBar {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard selectedType != currentOptions[index] else { return }
        setSelectedIndex(index, animated: true)
        selectEvent.call(currentOptions[index])
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index < buttons.count else { return }
        let button = buttons[index]
        selectedType = currentOptions[index]
        buttons.forEach { $0.isSelected = $0 == button }
        updateIndicator(animated: animated, to: button)
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerFilterBar: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        setupView(options: options)
        if options.mediaTypeFilter != currentOptions {
            currentOptions = options.mediaTypeFilter
            setupButtons(options: options)
        }
        
        if #available(iOS 26.0, *), !options.designRequiresCompatibility {
            return
        }
        
        backgroundColor = options.theme[color: .toolBar]
        indicator.backgroundColor = options.theme[color: .primary]
        
        for button in buttons {
            button.setTitleColor(options.theme[color: .text], for: .selected)
            button.setTitleColor(options.theme[color: .subText], for: .normal)
        }
    }
}

// MARK: - UI
extension PickerFilterBar {
    
    private func setupView(options: PickerOptionsInfo) {
        guard isFirst else { return }
        isFirst = false
        if #available(iOS 26.0, *), !options.designRequiresCompatibility {
            addSubview(segmentedControl)
            segmentedControl.snp.makeConstraints { make in
                make.edges.equalToSuperview()
//                make.width.equalTo(180)
                make.height.equalTo(48)
            }
            return
        }
        
        addSubview(hStackView)
        addSubview(indicator)
        hStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }
        indicator.snp.makeConstraints { make in
            make.width.equalTo(14)
            make.height.equalTo(4)
            make.bottom.equalToSuperview().offset(-7)
        }
    }
    
    private func setupButtons(options: PickerOptionsInfo) {
        if #available(iOS 26.0, *), !options.designRequiresCompatibility {
            segmentedControl.removeAllSegments()
            segmentedActions = []
            for (index, option) in currentOptions.enumerated() {
                let action = UIAction(title: option.title) { [weak self] _ in
                    guard let self = self else { return }
                    guard self.selectedType != self.currentOptions[index] else { return }
                    self.selectedType = self.currentOptions[index]
                    self.selectEvent.call(self.currentOptions[index])
                }
                segmentedActions.append(action)
                segmentedControl.insertSegment(action: action, at: segmentedActions.count-1, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 0
            return
        }
        
        hStackView.arrangedSubviews.forEach {
            hStackView.removeArrangedSubview($0)
        }
        buttons = []
        if currentOptions.isEmpty { return }
        for (idx, option) in currentOptions.enumerated() {
            let button = createButton(index: idx, option: option)
            button.isSelected = idx == 0
            buttons.append(button)
            hStackView.addArrangedSubview(button)
        }
        updateIndicator(animated: false, to: buttons.first!)
    }
    
    private func updateIndicator(animated: Bool, to view: UIView) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            self.indicator.snp.remakeConstraints { make in
                make.width.equalTo(14)
                make.height.equalTo(4)
                make.bottom.equalToSuperview().offset(-7)
                make.centerX.equalTo(view)
            }
            self.layoutIfNeeded()
        }
    }
    
    private func createButton(index: Int, option: PickerMediaTypeFilter) -> UIButton {
        let view = UIButton(type: .custom)
        view.tag = index
        view.setTitle(option.title, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return view
    }
}
