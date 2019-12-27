//
//  CaptureConfigViewController.swift
//  Example
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class CaptureConfigViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        let title = BundleHelper.localizedString(key: "Open camera")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.white
    }
    
    @IBAction func openPickerTapped() {
        let controller = ImageCaptureController(delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
}

extension CaptureConfigViewController: ImageCaptureControllerDelegate {
    
    func imageCaptureDidCancel(_ capture: ImageCaptureController) {
        capture.dismiss(animated: true, completion: nil)
    }
    
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing media: URL, type: CaptureMediaType) {
        switch type {
        case .photo:
            guard let data = try? Data(contentsOf: media) else { return }
            guard let image = UIImage(data: data) else { return }
            let controller = EditorResultViewController()
            controller.imageView.image = image
            show(controller, sender: nil)
            capture.dismiss(animated: true, completion: nil)
        case .video:
            break
        }
    }
}
