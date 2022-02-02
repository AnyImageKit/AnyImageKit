//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorController: AnyImageViewController {
    
    private let resource: EditorPhotoResource
    
    @Injected(\.photoOptions)
    private var options: EditorPhotoOptionsInfo
    private let viewModel = PhotoEditorViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private var stack: PhotoEditingStack { viewModel.stack }
    
    private var continuation: CheckedContinuation<EditorResult, Error>?
    
    private lazy var contentView: PhotoEditorContentView = {
        let view = PhotoEditorContentView(viewModel: viewModel)
        return view
    }()
    private lazy var toolView: PhotoEditorToolView = {
        let view = PhotoEditorToolView(viewModel: viewModel)
        return view
    }()
    
    init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo) {
        self.resource = resource
        super.init(nibName: nil, bundle: nil)
        self.options = options
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .black
//        view.backgroundColor = .lightGray
        
        Task {
            do {
                // TODO: Loading
                viewModel.image = try await resource.loadImage()
                setupView()
                setupData()
                bindViewModel()
            } catch {
                _print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size != .zero && viewModel.containerSize == .zero {
            viewModel.containerSizeSubject.send(view.frame.size)
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        viewModel.safeAreaInsetsSubject.send(view.safeAreaInsets)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewModel.containerSizeSubject.send(size)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        viewModel.traitCollectionSubject.send(traitCollection)
    }
}

// MARK: - Observer
extension PhotoEditorController {
    
    private func bindViewModel() {
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .back:
                self.continuation?.resume(throwing: AnyImageError.exportCanceled)
            case .done:
                self.output()
            case .mosaicDidCreate:
                self.stack.mosaicImages = self.contentView.mosaic.mosaicImage
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Output
extension PhotoEditorController {
    
    func edit() async throws -> EditorResult {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
        }
    }
    
    private func output() {
        guard let continuation = continuation else { return }
        
//        contentView.deactivateAllTextView()
        guard let image = getResultImage() else {
            continuation.resume(throwing: AnyImageError.exportFailed)
            return
        }
//        setPlaceholdImage(image)
        stack.setOutputImage(image)
        saveEditPath()
        
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            continuation.resume(throwing: AnyImageError.invalidData)
            return
        }
        guard let url = FileHelper.write(photoData: data, fileType: .jpeg) else {
            continuation.resume(throwing: AnyImageError.fileWriteFailed)
            return
        }
        
        continuation.resume(returning: EditorResult(mediaURL: url, type: .photo, isEdited: stack.edit.isEdited))
    }
    
    /// 获取最终的图片
    private func getResultImage() -> UIImage? {
//        stack.cropRect = contentView.cropContext.cropRealRect
        let tmpScale = contentView.scrollView.zoomScale
        let tmpOffset = contentView.scrollView.contentOffset
        let tmpContentSize = contentView.scrollView.contentSize
        contentView.scrollView.zoomScale = contentView.scrollView.minimumZoomScale
        stack.cropImageViewFrame = contentView.imageView.frame
        contentView.scrollView.zoomScale = tmpScale
        contentView.scrollView.contentOffset = tmpOffset
        contentView.scrollView.contentSize = tmpContentSize
        
        // 由于 TextView 的位置是基于放大后图片的位置，所以在输出时要改回原始比例计算坐标位置
//        let textScale = stack.originImageViewBounds.size.width / contentView.imageView.bounds.width
//        contentView.calculateFinalFrame(with: textScale)
        
        return stack.output()
    }
    
    /// 存储编辑记录
    private func saveEditPath() {
        if options.cacheIdentifier.isEmpty { return }
        stack.save()
    }
}

// MARK: - Private
extension PhotoEditorController {
    
    private func setupData() {
        stack.originImage = viewModel.image
        stack.originImageViewBounds = contentView.imageView.bounds
    }
}

// MARK: - UI
extension PhotoEditorController {
    
    private func setupView() {
        view.addSubview(contentView)
        view.addSubview(toolView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        toolView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
