//
//  PickerConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class PickerConfigViewController: UITableViewController {
    
    var config = ImagePickerController.Config()
    
    var editorConfig = ImagePickerController.EditorConfig()
    
    var captureConfig = ImagePickerController.CaptureConfig()
    
    var isFullScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Picker"
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 500 / 1200))
        imageView.image = UIImage(named: "TitleMapPicker")
        tableView.tableHeaderView = imageView
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigation() {
        let title = BundleHelper.localizedString(key: "Open picker")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    // MARK: - Target
    
    @IBAction func openPickerTapped() {
        config.enableDebugLog = true
        config.selectOptions = [.video]
        editorConfig.options = [.photo, .video]
        let controller = ImagePickerController(config: config, editorConfig: editorConfig, captureConfig: captureConfig, delegate: self)
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = isFullScreen ? .fullScreen : .automatic
        }
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ConfigRowType.allCases.count
        case 1:
            return EditorConfigRowType.allCases.count
        case 2:
            return CaptureConfigRowType.allCases.count
        case 3:
            return OtherConfigRowType.allCases.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        
        let rowType: RowTypeRule
        switch indexPath.section {
        case 0:
            rowType = ConfigRowType.allCases[indexPath.row]
        case 1:
            rowType = EditorConfigRowType.allCases[indexPath.row]
        case 2:
            rowType = CaptureConfigRowType.allCases[indexPath.row]
        case 3:
            rowType = OtherConfigRowType.allCases[indexPath.row]
        default:
            fatalError()
        }
        
        cell.textLabel?.text = BundleHelper.localizedString(key: rowType.title)
        cell.detailTextLabel?.text = rowType.defaultValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let rowType = ConfigRowType.allCases[indexPath.row]
            switch rowType {
            case .theme:
                themeTapped()
            case .selectLimit:
                selectLimitTapped()
            case .columnNumber:
                columnNumberTapped()
            case .allowUseOriginalImage:
                allowUseOriginalImageTapped()
            case .albumOptions:
                albumOptionsTapped()
            case .selectOptions:
                selectOptionsTapped()
            case .orderByDate:
                orderbyDateTapped()
            }
        case 1:
            let rowType = EditorConfigRowType.allCases[indexPath.row]
            switch rowType {
            case .editorOptions:
                editorOptionsTapped()
            }
        case 2:
            let rowType = CaptureConfigRowType.allCases[indexPath.row]
            switch rowType {
            case .captureOptions:
                captureMediaOptionsTapped()
            }
        case 3:
            let rowType = OtherConfigRowType.allCases[indexPath.row]
            switch rowType {
            case .fullScreen:
                fullScreenTapped()
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Config"
        case 1:
            return "Editor Config"
        case 2:
            return "Capture Config"
        case 3:
            return "Other config"
        default:
            return nil
        }
    }
}

// MARK: - ImagePickerControllerDelegate
extension PickerConfigViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool) {
        print(assets)
        let controller = PickerResultViewController()
        controller.assets = assets
        show(controller, sender: nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Tapped
extension PickerConfigViewController {
    
    private func themeTapped() {
        let indexPath = ConfigRowType.theme.indexPath
        let alert = UIAlertController(title: "Theme", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Auto", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .init(style: .auto)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Auto"
        }))
        alert.addAction(UIAlertAction(title: "Light", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .init(style: .light)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Light"
        }))
        alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .init(style: .dark)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Dark"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func selectLimitTapped() {
        let indexPath = ConfigRowType.selectLimit.indexPath
        let alert = UIAlertController(title: "SelectLimit", message: nil, preferredStyle: .alert)
        for i in 1...9 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { [weak self] (_) in
                self?.config.selectLimit = i
                self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(i)"
            }))
        }
        alert.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] (_) in
            self?.config.selectLimit = 20
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "20"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func columnNumberTapped() {
        let indexPath = ConfigRowType.columnNumber.indexPath
        let alert = UIAlertController(title: "ColumnNumber", message: nil, preferredStyle: .alert)
        for i in 3...5 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { [weak self] (_) in
                self?.config.columnNumber = i
                self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(i)"
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func allowUseOriginalImageTapped() {
        let indexPath = ConfigRowType.allowUseOriginalImage.indexPath
        config.allowUseOriginalImage.toggle()
        tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(config.allowUseOriginalImage)"
    }
    
    private func albumOptionsTapped() {
        let indexPath = ConfigRowType.albumOptions.indexPath
        let alert = UIAlertController(title: "AlbumOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Smart", style: .default, handler: { [weak self] (_) in
            self?.config.albumOptions = [.smart]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Smart"
        }))
        alert.addAction(UIAlertAction(title: "User Created", style: .default, handler: { [weak self] (_) in
            self?.config.albumOptions = [.userCreated]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "User Created"
        }))
        alert.addAction(UIAlertAction(title: "Smart+User Created", style: .default, handler: { [weak self] (_) in
            self?.config.albumOptions = [.smart, .userCreated]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Smart+User Created"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func selectOptionsTapped() {
        let indexPath = ConfigRowType.selectOptions.indexPath
        let alert = UIAlertController(title: "SelectOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photo, .video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo+Video"
        }))
        alert.addAction(UIAlertAction(title: "Photo+GIF+LivePhoto", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photo, .photoGIF, .photoLive]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo+GIF+LivePhoto"
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photo]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo"
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Video"
        }))
        alert.addAction(UIAlertAction(title: "GIF", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photoGIF]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "GIF"
        }))
        alert.addAction(UIAlertAction(title: "LivePhoto", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photoLive]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "LivePhoto"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func orderbyDateTapped() {
        let indexPath = ConfigRowType.orderByDate.indexPath
        let alert = UIAlertController(title: "OrderbyDate", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ASC", style: .default, handler: { [weak self] (_) in
            self?.config.orderByDate = .asc
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "ASC"
        }))
        alert.addAction(UIAlertAction(title: "DESC", style: .default, handler: { [weak self] (_) in
            self?.config.orderByDate = .desc
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "DESC"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func editorOptionsTapped() {
        let indexPath = EditorConfigRowType.editorOptions.indexPath
        let alert = UIAlertController(title: "EditorOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { [weak self] (_) in
            self?.editorConfig.options = []
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "None"
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.editorConfig.options = [.photo]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func captureMediaOptionsTapped() {
        let indexPath = CaptureConfigRowType.captureOptions.indexPath
        let alert = UIAlertController(title: "CaptureOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { [weak self] (_) in
            self?.captureConfig.options = []
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "None"
        }))
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (_) in
            self?.captureConfig.options = [.photo, .video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo+Video"
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.captureConfig.options = [.photo]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo"
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (_) in
            self?.captureConfig.options = [.video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Video"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Other Config
    
    private func fullScreenTapped() {
        let indexPath = OtherConfigRowType.fullScreen.indexPath
        isFullScreen.toggle()
        tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(isFullScreen)"
    }
}

// MARK: - Enum
extension PickerConfigViewController {
    
    // MARK: - Config
    enum ConfigRowType: Int, CaseIterable, RowTypeRule {
        case theme = 0
        case selectLimit
        case columnNumber
        case allowUseOriginalImage
        case albumOptions
        case selectOptions
        case orderByDate
        
        var title: String {
            switch self {
            case .theme:
                return "Theme"
            case .selectLimit:
                return "SelectLimit"
            case .columnNumber:
                return "ColumnNumber"
            case .allowUseOriginalImage:
                return "UseOriginalImage"
            case .albumOptions:
                return "AlbumOptions"
            case .selectOptions:
                return "SelectOptions"
            case .orderByDate:
                return "OrderByDate"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .theme:
                return "Auto"
            case .selectLimit:
                return "9"
            case .columnNumber:
                return "4"
            case .allowUseOriginalImage:
                return "true"
            case .albumOptions:
                return "Smart+User Created"
            case .selectOptions:
                return "Photo"
            case .orderByDate:
                return "ASC"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 0)
        }
    }
    
    // MARK: - Editor Config
    enum EditorConfigRowType: Int, CaseIterable, RowTypeRule {
        case editorOptions = 0
        
        var title: String {
            switch self {
            case .editorOptions:
                return "EditorOptions"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .editorOptions:
                return "None"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 1)
        }
    }
    
    // MARK: - Capture Config
    enum CaptureConfigRowType: Int, CaseIterable, RowTypeRule {
        case captureOptions = 0
        
        var title: String {
            switch self {
            case .captureOptions:
                return "CaptureOptions"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .captureOptions:
                return "None"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 2)
        }
    }
    
    // MARK: - Other Config
    enum OtherConfigRowType: Int, CaseIterable, RowTypeRule {
        case fullScreen = 0
        
        var title: String {
            switch self {
            case .fullScreen:
                return "FullScreen"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .fullScreen:
                return "true"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 3)
        }
    }
}
