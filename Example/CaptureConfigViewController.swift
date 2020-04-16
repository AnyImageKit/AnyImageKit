//
//  CaptureConfigViewController.swift
//  Example
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVKit
import AnyImageKit

final class CaptureConfigViewController: UITableViewController {
    
    var options =  CaptureOptionsInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    private func setupView() {
        tableView.register(ConfigCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Capture"
        let title = BundleHelper.localizedString(key: "OpenCamera")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openCaptureTapped))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let imageViewHeight = view.bounds.width * 500 / 1200
        if let headerView = tableView.tableHeaderView as? UIImageView, headerView.bounds.height == imageViewHeight {
            return
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: imageViewHeight))
        imageView.image = UIImage(named: "TitleMapCapture")
        tableView.tableHeaderView = imageView
    }
    
    // MARK: - Target
    
    @IBAction func openCaptureTapped() {
        options.enableDebugLog = true
        let controller = ImageCaptureController(options: options, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = RowType.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConfigCell
        cell.titleLabel.text = BundleHelper.localizedString(key: rowType.title)
        cell.tagsButton.setTitle(rowType.options, for: .normal)
        cell.contentLabel.text = rowType.defaultValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType.allCases[indexPath.row]
        switch rowType {
        case .mediaOptions:
            mediaOptionsTapped()
        case .photoAspectRatio:
            photoAspectRatioTapped()
        case .preferredPositions:
            preferredPositionsTapped()
        case .flashMode:
            flashModeTapped()
        case .videoMaximumDuration:
             videoMaximumDurationTapped()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Options"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

extension CaptureConfigViewController: ImageCaptureControllerDelegate {
    
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing mediaURL: URL, type: MediaType) {
        switch type {
        case .photo:
            capture.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                guard let data = try? Data(contentsOf: mediaURL) else { return }
                guard let image = UIImage(data: data) else { return }
                let controller = EditorResultViewController()
                controller.imageView.image = image
                self.show(controller, sender: nil)
            })
        case .video:
            capture.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                let player = AVPlayer(url: mediaURL)
                let controller = AVPlayerViewController()
                controller.player = player
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true) {
                    player.playImmediately(atRate: 1)
                }
            })
        case .photoLive, .photoGIF:
            // Not support yet
            break
        }
    }
}

extension CaptureConfigViewController {
    
    private func mediaOptionsTapped() {
        let indexPath = RowType.mediaOptions.indexPath
        let alert = UIAlertController(title: "Media Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (action) in
            self?.options.mediaOptions = [.photo, .video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (action) in
            self?.options.mediaOptions = [.photo]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (action) in
            self?.options.mediaOptions = [.video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func photoAspectRatioTapped() {
        let indexPath = RowType.photoAspectRatio.indexPath
        let alert = UIAlertController(title: "Photo Aspect Ratio", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "1:1", style: .default, handler: { [weak self] (action) in
            self?.options.photoAspectRatio = .ratio1x1
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "4:3", style: .default, handler: { [weak self] (action) in
            self?.options.photoAspectRatio = .ratio4x3
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "16:9", style: .default, handler: { [weak self] (action) in
            self?.options.photoAspectRatio = .ratio16x9
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func preferredPositionsTapped() {
        let indexPath = RowType.preferredPositions.indexPath
        let alert = UIAlertController(title: "Preferred Positions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back+Front", style: .default, handler: { [weak self] (action) in
            self?.options.preferredPositions = [.back, .front]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Front+Back", style: .default, handler: { [weak self] (action) in
            self?.options.preferredPositions = [.front, .back]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Front", style: .default, handler: { [weak self] (action) in
            self?.options.preferredPositions = [.front]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { [weak self] (action) in
            self?.options.preferredPositions = [.back]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func flashModeTapped() {
        let indexPath = RowType.flashMode.indexPath
        let alert = UIAlertController(title: "Flash Mode", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Auto", style: .default, handler: { [weak self] (action) in
            self?.options.flashMode = .auto
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Off", style: .default, handler: { [weak self] (action) in
            self?.options.flashMode = .off
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "On", style: .default, handler: { [weak self] (action) in
            self?.options.flashMode = .on
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func videoMaximumDurationTapped() {
        let indexPath = RowType.videoMaximumDuration.indexPath
        let alert = UIAlertController(title: "Video Maximum Duration", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "10", style: .default, handler: { [weak self] (action) in
            self?.options.videoMaximumDuration = 10
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] (action) in
            self?.options.videoMaximumDuration = 20
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "30", style: .default, handler: { [weak self] (action) in
            self?.options.videoMaximumDuration = 30
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "60", style: .default, handler: { [weak self] (action) in
            self?.options.videoMaximumDuration = 60
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "120", style: .default, handler: { [weak self] (action) in
            self?.options.videoMaximumDuration = 120
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Enum
extension CaptureConfigViewController {
    
    enum RowType: Int, CaseIterable {
        case mediaOptions = 0
        case photoAspectRatio
        case preferredPositions
        case flashMode
        case videoMaximumDuration
        
        var title: String {
            switch self {
            case .mediaOptions:
                return "MediaOptions"
            case .photoAspectRatio:
                return "PhotoAspectRatio"
            case .preferredPositions:
                return "PreferredPositions"
            case .flashMode:
                return "FlashMode"
            case .videoMaximumDuration:
                return "VideoMaximumDuration"
            }
        }
        
        var options: String {
            switch self {
            case .mediaOptions:
                return ".mediaOptions"
            case .photoAspectRatio:
                return ".photoAspectRatio"
            case .preferredPositions:
                return ".preferredPositions"
            case .flashMode:
                return ".flashMode"
            case .videoMaximumDuration:
                return ".videoMaximumDuration"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .mediaOptions:
                return "Photo+Video"
            case .photoAspectRatio:
                return "4:3"
            case .preferredPositions:
                return "Back+Front"
            case .flashMode:
                return "Off"
            case .videoMaximumDuration:
                return "20"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 0)
        }
    }
}
