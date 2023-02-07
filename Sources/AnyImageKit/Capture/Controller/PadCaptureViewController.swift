//
//  PadCaptureViewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/6/19.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

protocol PadCaptureViewControllerDelegate: AnyObject {
    
    func captureDidCancel(_ capture: PadCaptureViewController)
    func capture(_ capture: PadCaptureViewController, didOutput mediaURL: URL, type: MediaType)
}

final class PadCaptureViewController: AnyImageViewController {

    weak var delegate: PadCaptureViewControllerDelegate?
    
    private let options: CaptureOptionsInfo
    
    init(options: CaptureOptionsInfo) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        showPickerController()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = .black
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PadCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.captureDidCancel(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        func exit() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.captureDidCancel(self)
            }
        }
        
        let infoKey = UIImagePickerController.InfoKey.self
        guard let type = info[infoKey.mediaType] as? String else { exit(); return }
        guard let mediaType = MediaType(utType: type) else { exit(); return }
        switch mediaType {
        case .photo:
            trackObserver?.track(event: .capturePhoto, userInfo: [:])
            guard let image = info[infoKey.originalImage] as? UIImage else { exit(); return }
            guard let imageData = image.jpegData(compressionQuality: 1.0) else { exit(); return }
            guard let url = FileHelper.write(photoData: imageData, fileType: .jpeg) else { exit(); return }
            delegate?.capture(self, didOutput: url, type: .photo)
        case .video:
            trackObserver?.track(event: .captureVideo, userInfo: [:])
            guard let url = info[infoKey.mediaURL] as? URL else { exit(); return }
            view.hud.show()
            convertMovToMp4(url) { [weak self] (outputURL) in
                self?.view.hud.hide()
                guard let outputURL = outputURL else { exit(); return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.capture(self, didOutput: outputURL, type: .video)
                }
            }
        default:
            exit()
        }
    }
}

// MARK: - Private
extension PadCaptureViewController {
    
    private func showPickerController() {
        var mediaTypes: [String] = []
        if options.mediaOptions.contains(.photo) {
            mediaTypes.append(MediaType.photo.utType)
        }
        if options.mediaOptions.contains(.video) {
            mediaTypes.append(MediaType.video.utType)
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.allowsEditing = false
        controller.mediaTypes = mediaTypes
        controller.cameraDevice = (options.preferredPositions.first ?? .back) == .back ? .rear : .front
        controller.cameraFlashMode = options.flashMode.cameraFlashMode
        controller.videoMaximumDuration = options.videoMaximumDuration
        controller.delegate = self
        present(controller, animated: false, completion: nil)
    }
    
    private func convertMovToMp4(_ url: URL, completion: @escaping ((URL?) -> Void)) {
        let avAsset = AVURLAsset(url: url, options: nil)
        let outputURL = FileHelper.getTemporaryUrl(by: .video, fileType: .mp4)
        
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            if exportSession.status == .failed {
                _print("Failed convert MOV to MP4")
                completion(nil)
            } else if exportSession.status == .completed {
                _print("Successed convert MOV to MP4")
                _print("MP4 path: \(outputURL)")
                completion(outputURL)
            }
        }
    }
}
