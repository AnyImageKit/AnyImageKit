//
//  EditorConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class EditorConfigViewController: UITableViewController {

    var config = ImageEditorController.PhotoConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Editor"
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 500 / 1200))
        imageView.image = UIImage(named: "TitleMapEditor")
        tableView.tableHeaderView = imageView
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigation() {
        let title = BundleHelper.localizedString(key: "Open editor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    @objc private func openPickerTapped() {
        config.enableDebugLog = true
        let image = UIImage(named: "EditorTestImage")!
        let controller = ImageEditorController(image: image, config: config, delegate: self)
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
        let cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        let rowType = RowType.allCases[indexPath.row]
        cell.textLabel?.text = BundleHelper.localizedString(key: rowType.title)
        cell.detailTextLabel?.text = rowType.defaultValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType.allCases[indexPath.row]
        switch rowType {
        case .editOptions:
            editOptionsTapped()
        case .penWidth:
            penWidthTapped()
        case .mosaicOptions:
            mosaicOptionsTapped()
        case .mosaicWidth:
            mosaicWidthTapped()
        case .mosaicLevel:
            mosaicLevelTapped()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Config"
    }
}

// MARK: - ImageEditorPhotoDelegate
extension EditorConfigViewController: ImageEditorControllerDelegate {
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        let controller = EditorResultViewController()
        controller.imageView.image = photo
        show(controller, sender: nil)
        editor.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Tapped
extension EditorConfigViewController {
    
    private func editOptionsTapped() {
        let indexPath = RowType.editOptions.indexPath
        let alert = UIAlertController(title: "EditOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Pen+Text+Crop+Mosaic", style: .default, handler: { [weak self] (action) in
            self?.config.editOptions = [.pen, .crop, .mosaic]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Pen", style: .default, handler: { [weak self] (action) in
            self?.config.editOptions = [.pen]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Text", style: .default, handler: { [weak self] (action) in
            self?.config.editOptions = [.text]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Crop", style: .default, handler: { [weak self] (action) in
            self?.config.editOptions = [.crop]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Mosaic", style: .default, handler: { [weak self] (action) in
            self?.config.editOptions = [.mosaic]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func penWidthTapped() {
        let indexPath = RowType.penWidth.indexPath
        let alert = UIAlertController(title: "PenWidth", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "2.5", style: .default, handler: { [weak self] (action) in
            self?.config.penWidth = 2.5
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "5.0", style: .default, handler: { [weak self] (action) in
            self?.config.penWidth = 5.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "7.5", style: .default, handler: { [weak self] (action) in
            self?.config.penWidth = 7.5
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "10.0", style: .default, handler: { [weak self] (action) in
            self?.config.penWidth = 10.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicOptionsTapped() {
        let indexPath = RowType.mosaicOptions.indexPath
        let alert = UIAlertController(title: "MosaicOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Default+Colorful", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicOptions = [.default, .colorful]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Default", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicOptions = [.default]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Colorful", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicOptions = [.colorful]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicWidthTapped() {
        let indexPath = RowType.mosaicWidth.indexPath
        let alert = UIAlertController(title: "MosaicWidth", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "15.0", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicWidth = 15.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "20.0", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicWidth = 20.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "25.0", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicWidth = 25.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "30.0", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicWidth = 30.0
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func mosaicLevelTapped() {
        let indexPath = RowType.mosaicLevel.indexPath
        let alert = UIAlertController(title: "MosaicLevel", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicLevel = 20
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "30", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicLevel = 30
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "40", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicLevel = 40
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "50", style: .default, handler: { [weak self] (action) in
            self?.config.mosaicLevel = 50
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Enum
extension EditorConfigViewController {
    
    enum RowType: Int, CaseIterable {
        case editOptions = 0
        case penWidth
        case mosaicOptions
        case mosaicWidth
        case mosaicLevel
        
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
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 0)
        }
    }
}
