//
//  VideoEditorConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AnyImageKit
import AVKit

final class VideoEditorConfigViewController: UITableViewController {

    var options = EditorVideoOptionsInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "VideoEditor"
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(ConfigCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setupNavigation() {
        let title = Bundle.main.localizedString(forKey: "OpenEditor", value: nil, table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openEditorTapped))
    }
    
    // MARK: - Target
    
    @objc private func openEditorTapped() {
        options.enableDebugLog = true
        let videoURL = Bundle.main.url(forResource: "EditorTestVideo", withExtension: "mp4")!
        let controller = ImageEditorController(
            video: videoURL,
            placeholderImage: nil,
            options: options,
            delegate: self
        )
        controller.trackDelegate = self
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
        cell.setupData(rowType)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType.allCases[indexPath.row]
        rowType.getFunction(self)(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Options"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - ImageKitDataTrackDelegate
extension VideoEditorConfigViewController: ImageKitDataTrackDelegate {
    
    func dataTrack(page: AnyImagePage, state: AnyImagePageState) {
        switch state {
        case .enter:
            print("[Data Track] ENTER Page: \(page.rawValue)")
        case .leave:
            print("[Data Track] LEAVE Page: \(page.rawValue)")
        }
    }
    
    func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any]) {
        print("[Data Track] EVENT: \(event.rawValue), userInfo: \(userInfo)")
    }
}

// MARK: - ImageEditorPhotoDelegate
extension VideoEditorConfigViewController: ImageEditorControllerDelegate {
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        if result.type == .video {
            let controller = AVPlayerViewController()
            controller.player = AVPlayer(url: result.mediaURL)
            show(controller, sender: nil)
            editor.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Tapped
extension VideoEditorConfigViewController {
    
    private func editOptionsTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clip", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = EditorVideoToolOption.allCases
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func cropRangeTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "ClipRange", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "0...1", style: .default, handler: { [weak self] (action) in
            self?.options.clipRange = 0...1
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "0.25...0.75", style: .default, handler: { [weak self] (action) in
            self?.options.clipRange = 0.25...0.75
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "0...0.5", style: .default, handler: { [weak self] (action) in
            self?.options.clipRange = 0...0.5
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Enum
extension VideoEditorConfigViewController {
    
    enum RowType: Int, CaseIterable, RowTypeRule {
        case editOptions = 0
        case clipRange
        
        var title: String {
            switch self {
            case .editOptions:
                return "EditOptions"
            case .clipRange:
                return "ClipRange"
            }
        }
        
        var options: String {
            switch self {
            case .editOptions:
                return ".editOptions"
            case .clipRange:
                return ".clipRange"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .editOptions:
                return "Clip"
            case .clipRange:
                return "0...1"
            }
        }
        
        func getFunction<T>(_ controller: T) -> ((IndexPath) -> Void) where T : UIViewController {
            guard let controller = controller as? VideoEditorConfigViewController else { return { _ in } }
            switch self {
            case .editOptions:
                return controller.editOptionsTapped
            case .clipRange:
                return controller.cropRangeTapped
            }
        }
    }
}
