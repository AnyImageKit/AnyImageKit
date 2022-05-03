//
//  PhotoEditorContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine
import CoreImage
import Metal

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
    private(set) lazy var imageViewAdjust: UIImageView = {
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
        
        bindAdjust()
//        showFiltersInConsole()
//        outputImage()
        
        imageViewAdjust.isHidden = true
        
//        let filter = CIFilter(name: "CIPhotoEffectNoir", parameters: ["inputImage":CIImage(image: self.viewModel.image)])
//        imageViewAdjust.image = UIImage(ciImage: filter!.outputImage!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindAdjust() {
        viewModel.actionSubject
            .throttle(for: .milliseconds(41), scheduler: DispatchQueue.main, latest: true)
            .sink(on: self) { (self, action) in
                switch action {
                case .adjustValueChanged(let present):
                    let filter = AdjustParameter(option: .exposure)
//                    print(filter.range.value(of: present))
                    self.setAdjust(name: filter.filterName, key: filter.key, value: filter.range.value(of: present))
                    
//                    self.imageViewAdjust.alpha = present
                default:
                    break
                }
            }.store(in: &cancellable)
    }
    
    private let adjustContext = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!, options: [.cacheIntermediates : false])
    
    private var imgB: CIImage?
    private var imgFil: CIImage?
    private var imgF: CIImage?
    
    func setAdjust(name: String, key: String, value: CGFloat) {
        
//        Task { @MainActor in
//            do {
//                let image = try await applyAdjust(name: name, key: key, value: value)
//                self.imageView.image = image
//            } catch {
//
//            }
//        }
        
        DispatchQueue.global().async {
//            let vector = CIVector(values: [0, 0, 0, 1.0], count: 4)

//            if self.imgB == nil {
                self.imgF = CIImage(image: self.viewModel.image)!
                .applyingFilter(name, parameters: [key: value])
//            }

//            if self.imgFil == nil {
//                self.imgFil = self.imgB!.applyingFilter("CIPhotoEffectNoir")
//            }
//
//            self.imgF = self.imgFil!
//                .applyingFilter("CIColorMatrix", parameters: ["inputAVector": vector])
//                .applyingFilter("CISourceAtopCompositing", parameters: ["inputBackgroundImage": self.imgB!])

            guard let cgImage = self.adjustContext.createCGImage(self.imgF!, from: self.imgF!.extent) else {
                return
            }

            DispatchQueue.main.async {
                self.imageView.image = UIImage(cgImage: cgImage)
            }
        }
        
        
        
        
//        Task {
//            do {
////                let rgba: [CGFloat] = [0, 0, 0, 0.9]
//                let vector = CIVector(values: [0, 0, 0, value], count: 4)
//                
//                if imgB == nil {
//                    imgB = CIImage(image: self.viewModel.image)!
//                        .applyingFilter(name, parameters: [key: 2.0])
//                }
//                
//                if imgFil == nil {
//                    imgFil = imgB!.applyingFilter("CIPhotoEffectNoir")
//                }
//                
//                imgF = imgFil!
//                    .applyingFilter("CIColorMatrix", parameters: ["inputAVector": vector])
//                    .applyingFilter("CISourceAtopCompositing", parameters: ["inputBackgroundImage": imgB!])
//                
//                if let cgImage = adjustContext.createCGImage(imgF!, from: imgF!.extent) {
//                    imageView.image = UIImage(cgImage: cgImage)
//                }
//                
////                let im = CIImage(image: self.viewModel.image)!
////                    .applyingFilter("CIPhotoEffectNoir")
////                    .applyingFilter("CIColorMatrix", parameters: ["inputAVector": vector])
////                    .applyingFilter(name, parameters: [key: 2.0])
//                
//                
////                let image = try await applyAdjust(name: name, key: key, value: value)
////                imageView.image = image
//                
////                let im = CIImage(image: self.viewModel.image)!
////                let im1 = im.applyingFilter("CIPhotoEffectNoir").applyingFilter(name, parameters: [key: value])
////                imageViewAdjust.image = UIImage(ciImage: im1)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
    }
    
    func applyAdjust(name: String, key: String, value: CGFloat) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: AnyImageError.invalidData)
                return
            }
            guard let filter = CIFilter(name: name) else {
                continuation.resume(throwing: AnyImageError.invalidData)
                return
            }
            
            let inputImage = CIImage(image: self.viewModel.image)

            filter.setValue(inputImage, forKey: kCIInputImageKey)
            filter.setValue(value, forKey: key)
            
            guard let outputImage = filter.outputImage else {
                continuation.resume(throwing: AnyImageError.invalidData)
                return
            }
//            continuation.resume(returning: UIImage(ciImage: outputImage))
            
            guard let cgImage = adjustContext.createCGImage(outputImage, from: outputImage.extent) else {
                continuation.resume(throwing: AnyImageError.invalidData)
                return
            }
            continuation.resume(returning: UIImage(cgImage: cgImage))
        }
    }
    
    func outputImage() {
//        guard let filter = CIFilter(name: "CIPhotoEffectNoir") else { return }
        guard let filter = CIFilter(name: "CIExposureAdjust") else { return }
//        guard let filter = CIFilter(name: "CIGammaAdjust") else { return }
//        guard let filter = CIFilter(name: "CIHueAdjust") else { return }
        
        
        print(filter.attributes)
        
        
        
//        print("==>")
//        print(CIFilter.filterNames(inCategory: kCICategoryColorEffect))
        
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: viewModel.image)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
//        filter.setValue(0.2, forKey: kCIInputAngleKey)
        
        filter.setValue(2.0, forKey: "inputEV") //CIExposureAdjust
//        filter.setValue(0.85, forKey: "inputPower") //CIGammaAdjust
        
        
        guard let outputImage = filter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        self.imageView.image = UIImage(cgImage: cgImage)
    }
    
//    func noiseReduction(inputImage: CIImage) -> CIImage? {
//        let noiseReductionfilter = CIFilter(name: "CINoiseReduction")
//        noiseReductionfilter.inputImage = inputImage
//        noiseReductionfilter.noiseLevel = 0.2
//        noiseReductionfilter.sharpness = 0.4
//        return noiseReductionfilter.outputImage
//    }
    
    func showFiltersInConsole() {
        // kCICategoryColorEffect kCICategoryBuiltIn
        let filterNames = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print("=======>")
        print(filterNames.count)
        print(filterNames)
        for filterName in filterNames {
            let filter = CIFilter(name: filterName as String)
            if let attributes = filter?.attributes {
                print(attributes.description)
                print("\n=======>\n")
            }
            
        }
        
//        inputImage, inputIntensity
    }
    
    // CIExposureAdjust
    
//    ["原图", "鲜明" "鲜暖色", "鲜冷色", "反差色", "反差暖色", "反差冷色", "单色", "银色调", "黑白"]
//    ["", "鲜明" "鲜暖色", "鲜冷色", "反差色", "反差暖色", "反差冷色", "CIPhotoEffectMono", "CIPhotoEffectTonal", "CIPhotoEffectNoir"]
    //  CIPhotoEffectMono, ?, CIPhotoEffectNoir
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
        scrollView.addSubview(imageViewAdjust)
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
        
        imageViewAdjust.frame = CGRect(origin: .zero, size: imageSize)
        imageViewAdjust.center = viewModel.centerOfContentSize
        
        canvas.frame = CGRect(origin: .zero, size: imageSize)
        canvas.updateView(with: viewModel.stack.edit, force: true)
        
        mosaic.frame = CGRect(origin: .zero, size: imageSize)
        mosaic.updateView(with: viewModel.stack.edit)
        mosaic.updateFrame()
    }
    
    internal func updateSubviewFrame() {
//        mirrorCropView.snp.remakeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        canvas.frame = imageView.frame
        canvas.frame = CGRect(origin: .zero, size: imageView.frame.size)
        mosaic.frame = CGRect(origin: .zero, size: imageView.frame.size)
        
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
