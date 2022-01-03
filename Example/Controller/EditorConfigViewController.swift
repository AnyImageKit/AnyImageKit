//
//  EditorConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class EditorConfigViewController: UITableViewController {

    var options = EditorPhotoOptionsInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Editor"
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
        let image = UIImage(named: "EditorTestImage")!
        let controller = ImageEditorController(photo: image, options: options, delegate: self)
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
extension EditorConfigViewController: ImageKitDataTrackDelegate {
    
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
extension EditorConfigViewController: ImageEditorControllerDelegate {
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        if result.type == .photo {
            guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
            guard let photo = UIImage(data: photoData) else { return }
            let controller = EditorResultViewController()
            controller.imageView.image = photo
            show(controller, sender: nil)
            editor.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Tapped
extension EditorConfigViewController {
    
    private func editOptionsTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Brush+Text+Crop+Mosaic", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = EditorPhotoToolOption.allCases
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Brush", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = [.brush]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Text", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = [.text]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Crop", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = [.crop]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Mosaic", style: .default, handler: { [weak self] (action) in
            self?.options.toolOptions = [.mosaic]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func penWidthTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Brush Width", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "2.5", style: .default, handler: { [weak self] (action) in
            self?.options.brushWidth = 2.5
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "5.0", style: .default, handler: { [weak self] (action) in
            self?.options.brushWidth = 5.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "7.5", style: .default, handler: { [weak self] (action) in
            self?.options.brushWidth = 7.5
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "10.0", style: .default, handler: { [weak self] (action) in
            self?.options.brushWidth = 10.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicOptionsTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Mosaic Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Default+Colorful", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicOptions = [.default, .colorful]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Default", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicOptions = [.default]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Colorful", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicOptions = [.colorful]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicWidthTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Mosaic Width", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "15.0", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicWidth = 15.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "20.0", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicWidth = 20.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "25.0", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicWidth = 25.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "30.0", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicWidth = 30.0
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicLevelTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Mosaic Level", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicLevel = 20
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "30", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicLevel = 30
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "40", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicLevel = 40
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "50", style: .default, handler: { [weak self] (action) in
            self?.options.mosaicLevel = 50
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func cropOptionsTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Crop Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Free/1:1/3:4/4:3/9:16/16:9", style: .default, handler: { [weak self] (action) in
            self?.options.cropOptions = EditorCropOption.allCases
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Free", style: .default, handler: { [weak self] (action) in
            self?.options.cropOptions = [.free]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "1:1", style: .default, handler: { [weak self] (action) in
            self?.options.cropOptions = [.custom(w: 1, h: 1)]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Free/9:16/16:9", style: .default, handler: { [weak self] (action) in
            self?.options.cropOptions = [.free, .custom(w: 9, h: 16), .custom(w: 16, h: 9)]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Enum
extension EditorConfigViewController {
    
    enum RowType: Int, CaseIterable, RowTypeRule {
        case editOptions = 0
        case penWidth
        case mosaicOptions
        case mosaicWidth
        case mosaicLevel
        case cropOptions
        
        var title: String {
            switch self {
            case .editOptions:
                return "EditOptions"
            case .penWidth:
                return "PenWidth"
            case .mosaicOptions:
                return "MosaicOptions"
            case .mosaicWidth:
                return "MosaicWidth"
            case .mosaicLevel:
                return "MosaicLevel"
            case .cropOptions:
                return "CropOptions"
            }
        }
        
        var options: String {
            switch self {
            case .editOptions:
                return ".editOptions"
            case .penWidth:
                return ".brushWidth"
            case .mosaicOptions:
                return ".mosaicOptions"
            case .mosaicWidth:
                return ".mosaicWidth"
            case .mosaicLevel:
                return ".mosaicLevel"
            case .cropOptions:
                return ".cropOptions"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .editOptions:
                return "Pen+Text+Crop+Mosaic"
            case .penWidth:
                return "5.0"
            case .mosaicOptions:
                return "Default+Colorful"
            case .mosaicWidth:
                return "15.0"
            case .mosaicLevel:
                return "30"
            case .cropOptions:
                return "Free/1:1/3:4/4:3/9:16/16:9"
            }
        }
        
        func getFunction<T>(_ controller: T) -> ((IndexPath) -> Void) where T : UIViewController {
            guard let controller = controller as? EditorConfigViewController else { return { _ in } }
            switch self {
            case .editOptions:
                return controller.editOptionsTapped
            case .penWidth:
                return controller.penWidthTapped
            case .mosaicOptions:
                return controller.mosaicOptionsTapped
            case .mosaicWidth:
                return controller.mosaicWidthTapped
            case .mosaicLevel:
                return controller.mosaicLevelTapped
            case .cropOptions:
                return controller.cropOptionsTapped
            }
        }
    }
}
