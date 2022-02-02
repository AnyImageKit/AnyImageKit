//
//  PhotoEditorContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorContentView: UIView {

    var options: EditorPhotoOptionsInfo { viewModel.options }
    
    let viewModel: PhotoEditorViewModel
    
    var cancellable = Set<AnyCancellable>()
    
    private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.isScrollEnabled = true
        view.scrollsToTop = false
        view.clipsToBounds = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: viewModel.image)
        view.isUserInteractionEnabled = true
        return view
    }()
    private(set) lazy var canvas: Canvas = {
        let view = Canvas(viewModel: viewModel)
        return view
    }()
    private(set) lazy var mosaic: Mosaic = {
        let view = Mosaic(viewModel: viewModel)
        return view
    }()
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.viewModel.scrollView = scrollView
        setupView()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Observer
extension PhotoEditorContentView {
    
    private func bindViewModel() {
        viewModel.containerSizeSubject.sink { [weak self] _ in
            self?.layoutView()
        }.store(in: &cancellable)
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .toolOptionChanged(let option):
                self.scrollView.isScrollEnabled = !(option == .brush || option == .mosaic)
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - UI
extension PhotoEditorContentView {
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        imageView.addSubview(mosaic)
        imageView.addSubview(canvas)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSingleTapped)))
    }
    
    private func layoutView() {
        let maxSize = viewModel.containerSize
        let imageSize = viewModel.fitImageSize
        guard imageSize != .zero else { return }
        
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = viewModel.maximumZoomScale
        scrollView.contentSize = imageSize
        
        scrollView.contentInset = .zero //UIEdgeInsets(top: 44, left: 30, bottom: 100, right: 30)
        scrollView.contentOffset = .zero
        
        scrollView.frame = CGRect(origin: .zero, size: maxSize)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        imageView.center = viewModel.centerOfContentSize
        
        canvas.frame = CGRect(origin: .zero, size: imageSize)
        canvas.updateView(with: viewModel.stack.edit, force: true)
        
        mosaic.frame = CGRect(origin: .zero, size: imageSize)
        mosaic.updateView(with: viewModel.stack.edit)
    }
    
    internal func updateSubviewFrame() {
//        mirrorCropView.snp.remakeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        canvas.frame = imageView.frame
        canvas.frame = CGRect(origin: .zero, size: imageView.frame.size)
        mosaic.frame = CGRect(origin: .zero, size: imageView.bounds.size)
//        mosaic?.layoutSubviews()
    }
}

// MARK: - Target
extension PhotoEditorContentView {
    
    @objc private func onSingleTapped() {
        print("1")
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoEditorContentView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = viewModel.centerOfContentSize
        if scrollView.zoomScale >= 1.0 {
            updateSubviewFrame()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
