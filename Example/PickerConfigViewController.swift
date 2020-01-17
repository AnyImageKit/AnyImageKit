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
    
    var options = PickerOptionsInfo()
    
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
        tableView.register(ConfigCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableHeaderView = imageView
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigation() {
        let title = BundleHelper.localizedString(key: "OpenPicker")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    // MARK: - Target
    
    @IBAction func openPickerTapped() {
        options.enableDebugLog = true
        let controller = ImagePickerController(options: options, delegate: self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConfigCell
        cell.titleLabel.text = BundleHelper.localizedString(key: rowType.title)
        cell.tagsButton.setTitle(rowType.options, for: .normal)
        cell.contentLabel.text = rowType.defaultValue
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
            return "Options"
        case 1:
            return "Editor options"
        case 2:
            return "Capture options"
        case 3:
            return "Other options"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
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
        alert.addAction(UIAlertAction(title: "Auto", style: .default, handler: { [weak self] (action) in
            self?.options.theme = .init(style: .auto)
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Light", style: .default, handler: { [weak self] (action) in
            self?.options.theme = .init(style: .light)
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { [weak self] (action) in
            self?.options.theme = .init(style: .dark)
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func selectLimitTapped() {
        let indexPath = ConfigRowType.selectLimit.indexPath
        let alert = UIAlertController(title: "Select Limit", message: nil, preferredStyle: .alert)
        for i in 1...9 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { [weak self] (action) in
                self?.options.selectLimit = i
                (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(i)"
            }))
        }
        alert.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] (action) in
            self?.options.selectLimit = 20
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func columnNumberTapped() {
        let indexPath = ConfigRowType.columnNumber.indexPath
        let alert = UIAlertController(title: "Column Number", message: nil, preferredStyle: .alert)
        for i in 3...5 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { [weak self] (action) in
                self?.options.columnNumber = i
                (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(i)"
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func allowUseOriginalImageTapped() {
        let indexPath = ConfigRowType.allowUseOriginalImage.indexPath
        options.allowUseOriginalImage = !options.allowUseOriginalImage
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(options.allowUseOriginalImage)"
    }
    
    private func albumOptionsTapped() {
        let indexPath = ConfigRowType.albumOptions.indexPath
        let alert = UIAlertController(title: "Album Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Smart", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.smart]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "User Created", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.userCreated]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Smart+User Created", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.smart, .userCreated]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func selectOptionsTapped() {
        let indexPath = ConfigRowType.selectOptions.indexPath
        let alert = UIAlertController(title: "Select Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.photo, .video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo+GIF+LivePhoto", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.photo, .photoGIF, .photoLive]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.photo]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "GIF", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.photoGIF]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "LivePhoto", style: .default, handler: { [weak self] (action) in
            self?.options.selectOptions = [.photoLive]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func orderbyDateTapped() {
        let indexPath = ConfigRowType.orderByDate.indexPath
        let alert = UIAlertController(title: "Order By Date", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ASC", style: .default, handler: { [weak self] (action) in
            self?.options.orderByDate = .asc
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "DESC", style: .default, handler: { [weak self] (action) in
            self?.options.orderByDate = .desc
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func editorOptionsTapped() {
        let indexPath = EditorConfigRowType.editorOptions.indexPath
        let alert = UIAlertController(title: "Editor Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { [weak self] (action) in
            self?.options.editorOptions = []
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (action) in
            self?.options.editorOptions = [.photo]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func captureMediaOptionsTapped() {
        let indexPath = CaptureConfigRowType.captureOptions.indexPath
        let alert = UIAlertController(title: "Capture Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "None", style: .default, handler: { [weak self] (action) in
            self?.options.captureOptions.mediaOptions = []
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (action) in
            self?.options.captureOptions.mediaOptions = [.photo, .video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (action) in
            self?.options.captureOptions.mediaOptions = [.photo]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (action) in
            self?.options.captureOptions.mediaOptions = [.video]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Other Config
    
    private func fullScreenTapped() {
        let indexPath = OtherConfigRowType.fullScreen.indexPath
        isFullScreen.toggle()
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(isFullScreen)"
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
        
        var options: String {
            switch self {
            case .theme:
                return ".theme"
            case .selectLimit:
                return ".selectLimit"
            case .columnNumber:
                return ".columnNumber"
            case .allowUseOriginalImage:
                return ".allowUseOriginalImage"
            case .albumOptions:
                return ".albumOptions"
            case .selectOptions:
                return ".selectOptions"
            case .orderByDate:
                return ".orderByDate"
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
                return "false"
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
        
        var options: String {
            switch self {
            case .editorOptions:
                return ".editorOptions"
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
        
        var options: String {
            switch self {
            case .captureOptions:
                return ".captureOptions.mediaOptions"
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
        
        var options: String {
            switch self {
            case .fullScreen:
                return ".modalPresentationStyle"
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
