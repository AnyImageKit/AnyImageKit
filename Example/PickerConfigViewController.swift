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
    
    var isFullScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "AnyImagePicker"
        setupNavigation()
    }
    
    private func setupNavigation() {
        let title = BundleHelper.localizedString(key: "Open picker")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    // MARK: - Target
    
    @IBAction func openPickerTapped() {
        config.enableDebugLog = true
        let controller = ImagePickerController(config: config, delegate: self)
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = isFullScreen ? .fullScreen : .automatic
        }
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ConfigRowType.allCases.count
        case 1:
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
            case .selectOptions:
                selectOptionsTapped()
            case .orderByDate:
                orderbyDateTapped()
            case .captureMediaOptions:
                captureMediaOptionsTapped()
            }
        case 1:
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
            return "Other config"
        default:
            return nil
        }
    }
}

// MARK: - ImagePickerControllerDelegate
extension PickerConfigViewController: ImagePickerControllerDelegate {
    
    func imagePickerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool) {
        print(assets)
        let controller = PickerResultViewController()
        controller.assets = assets
        if let splitViewController = self.splitViewController {
            splitViewController.showDetailViewController(controller, sender: nil)
        } else {
            navigationController?.pushViewController(controller, animated: false)
        }
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
    
    private func captureMediaOptionsTapped() {
        let indexPath = ConfigRowType.captureMediaOptions.indexPath
        let alert = UIAlertController(title: "CaptureMediaOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { [weak self] (_) in
            self?.config.captureMediaOptions = []
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "None"
        }))
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (_) in
            self?.config.captureMediaOptions = [.photo, .video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo+Video"
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.config.captureMediaOptions = [.photo]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo"
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (_) in
            self?.config.captureMediaOptions = [.video]
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
    enum ConfigRowType: Int, CaseIterable, RowTypeRule {
        case theme = 0
        case selectLimit
        case columnNumber
        case allowUseOriginalImage
        case selectOptions
        case orderByDate
        case captureMediaOptions
        
        var title: String {
            switch self {
            case .theme:
                return "Theme"
            case .selectLimit:
                return "SelectLimit"
            case .columnNumber:
                return "ColumnNumber"
            case .allowUseOriginalImage:
                return "AllowUseOriginalImage"
            case .selectOptions:
                return "SelectOptions"
            case .orderByDate:
                return "OrderByDate"
            case .captureMediaOptions:
                return "CaptureMediaOptions"
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
            case .selectOptions:
                return "Photo"
            case .orderByDate:
                return "ASC"
            case .captureMediaOptions:
                return "None"
            }
        }
        
        var indexPath: IndexPath {
            return IndexPath(row: rawValue, section: 0)
        }
    }
    
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
            return IndexPath(row: rawValue, section: 1)
        }
    }
}
