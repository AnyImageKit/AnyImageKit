//
//  AdjustCollectionView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class AdjustCollectionView: ArcBaseCollectionView {
    
    let selectedEvent = CurrentValueSubject<Int, Never>(0)
    
    private var options: [EditorAdjustTypeOption] { viewModel.options.adjust.types }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private var models: [AdjustParameter]
    // -1 ~ 1
    private var values: [CGFloat] = [] // TODO: Move to stack
    
    init(arcOption: ArcOption, viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        self.models = viewModel.options.adjust.types.map { .init(option: $0) }
        self.values = self.models.map { $0.range.defaultValue }
        super.init(option: arcOption)
        setupView()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch selectedIndex {
        case .index(let index):
            collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: isRegular ? .centeredVertically : .centeredHorizontally)
        case .present:
            break
        }
    }
}

// MARK: - Observer
extension AdjustCollectionView {
    
    private func bindViewModel() {
        viewModel.actionSubject.sink(on: self) { (self, action) in
            switch action {
            case .adjustValueChanged(let present): // 0 ~ 1
                let index = self.selectedIndex.index
                let indexPath = IndexPath(row: index, section: 0)
                let model = self.models[index]
                self.values[index] = model.range.circlePresent(of: model.range.value(of: present))
                let cell = self.collectionView.cellForItem(at: indexPath) as? AdjustCollectionCell
                cell?.config(option: model.option, value: self.values[indexPath.row])
                cell?.hiddenLabel(false)
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - UI
extension AdjustCollectionView {
    
    private func setupView() {
        collectionView.registerCell(AdjustCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.autoScrollToItem = true
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension AdjustCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: isRegular ? .centeredVertically : .centeredHorizontally)
        selectedIndex = .index(indexPath.row)
        selectedEvent.send(selectedIndex.index)
        collectionView.visibleCells.forEach {
            ($0 as? AdjustCollectionCell)?.hiddenLabel(true)
        }
        
        // TODO: 再次点击关闭滤镜
    }
}

// MARK: - UICollectionViewDataSource
extension AdjustCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AdjustCollectionCell.self, for: indexPath)
        let model = models[indexPath.row]
        cell.config(option: model.option, value: values[indexPath.row])
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension AdjustCollectionView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach {
            ($0 as? AdjustCollectionCell)?.hiddenLabel(true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedIndex = .index(Int(floor(max(scrollView.contentOffset.x, scrollView.contentOffset.y) / (size.width + spacing))))
        selectedEvent.send(selectedIndex.index)
    }
}
