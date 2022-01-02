//
//  PickerConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class PickerConfigViewController: UITableViewController {
    
    var options = PickerOptionsInfo()
    
    var isFullScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Picker"
        let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    private func setupView() {
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(ConfigCell.self, forCellReuseIdentifier: ConfigCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Target
    
    @objc private func openPickerTapped() {
        options.enableDebugLog = true
        let controller = ImagePickerController(options: options, delegate: self)
        controller.trackDelegate = self
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = isFullScreen ? .fullScreen : .automatic
        }
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allCases[section].allRowCase.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = Section.allCases[indexPath.section].allRowCase[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConfigCell.reuseIdentifier, for: indexPath) as! ConfigCell
        cell.setupData(rowType)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionType = Section(rawValue: indexPath.section)!
        let rowType = sectionType.allRowCase[indexPath.row]
        rowType.getFunction(self)(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - ImagePickerControllerDelegate
extension PickerConfigViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        print(result.assets)
        let controller = PickerResultViewController()
        controller.assets = result.assets
        show(controller, sender: nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImageKitDataTrackDelegate
extension PickerConfigViewController: ImageKitDataTrackDelegate {
    
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

// MARK: - Tapped
extension PickerConfigViewController {
    
    private func themeTapped(_ indexPath: IndexPath) {
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
    
    private func selectLimitTapped(_ indexPath: IndexPath) {
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
    
    private func columnNumberTapped(_ indexPath: IndexPath) {
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
    
    private func allowUseOriginalImageTapped(_ indexPath: IndexPath) {
        options.allowUseOriginalImage = !options.allowUseOriginalImage
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(options.allowUseOriginalImage)"
    }
    
    private func selectionTapActionTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Selection Tap Action", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Preview", style: .default, handler: { [weak self] (action) in
            self?.options.selectionTapAction = .preview
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Quick Pick", style: .default, handler: { [weak self] (action) in
            self?.options.selectionTapAction = .quickPick
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Open Editor", style: .default, handler: { [weak self] (action) in
            self?.options.selectionTapAction = .openEditor
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func albumOptionsTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Album Options", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Smart", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.smart]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "User Created", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.userCreated]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Shared", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.shared]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Smart+User Created", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.smart, .userCreated]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Smart+User Created+Shared", style: .default, handler: { [weak self] (action) in
            self?.options.albumOptions = [.smart, .userCreated, .shared]
            (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func selectOptionsTapped(_ indexPath: IndexPath) {
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
    
    private func orderbyDateTapped(_ indexPath: IndexPath) {
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
    
    private func editorOptionsTapped(_ indexPath: IndexPath) {
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
    
    private func saveEditedAssetTapped(_ indexPath: IndexPath) {
        options.saveEditedAsset = !options.saveEditedAsset
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(options.saveEditedAsset)"
    }
    
    private func captureMediaOptionsTapped(_ indexPath: IndexPath) {
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
    
    private func fullScreenTapped(_ indexPath: IndexPath) {
        isFullScreen.toggle()
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(isFullScreen)"
    }
}

// MARK: - Enum
extension PickerConfigViewController {
    
    // MARK: - Section
    enum Section: Int, CaseIterable {
        case config
        case editor
        case capture
        case other
        
        var title: String? {
            switch self {
            case .config:
                return "Options"
            case .editor:
                return "Editor Options"
            case .capture:
                return "Capture Options"
            case .other:
                return "UIViewController Options"
            }
        }
        
        var allRowCase: [RowTypeRule] {
            switch self {
            case .config:
                return ConfigRowType.allCases
            case .editor:
                return EditorConfigRowType.allCases
            case .capture:
                return CaptureConfigRowType.allCases
            case .other:
                return OtherConfigRowType.allCases
            }
        }
    }
    
    // MARK: - Config
    enum ConfigRowType: Int, CaseIterable, RowTypeRule {
        case theme = 0
        case selectLimit
        case columnNumber
        case allowUseOriginalImage
        case selectionTapAction
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
            case .selectionTapAction:
                return "SelectionTapAction"
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
            case .selectionTapAction:
                return ".selectionTapAction"
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
            case .selectionTapAction:
                return "Preview"
            case .albumOptions:
                return "Smart+User Created"
            case .selectOptions:
                return "Photo"
            case .orderByDate:
                return "ASC"
            }
        }

        func getFunction<T: UIViewController>(_ controller: T) -> ((IndexPath) -> Void) {
            guard let controller = controller as? PickerConfigViewController else { return { _ in } }
            switch self {
            case .theme:
                return controller.themeTapped
            case .selectLimit:
                return controller.selectLimitTapped
            case .columnNumber:
                return controller.columnNumberTapped
            case .allowUseOriginalImage:
                return controller.allowUseOriginalImageTapped
            case .selectionTapAction:
                return controller.selectionTapActionTapped
            case .albumOptions:
                return controller.albumOptionsTapped
            case .selectOptions:
                return controller.selectOptionsTapped
            case .orderByDate:
                return controller.orderbyDateTapped
            }
        }
    }
    
    // MARK: - Editor Config
    enum EditorConfigRowType: Int, CaseIterable, RowTypeRule {
        case editorOptions = 0
        case saveEditedAsset
        
        var title: String {
            switch self {
            case .editorOptions:
                return "EditorOptions"
            case .saveEditedAsset:
                return "SaveEditedAsset"
            }
        }
        
        var options: String {
            switch self {
            case .editorOptions:
                return ".editorOptions"
            case .saveEditedAsset:
                return ".saveEditedAsset"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .editorOptions:
                return "None"
            case .saveEditedAsset:
                return "true"
            }
        }
        
        func getFunction<T>(_ controller: T) -> ((IndexPath) -> Void) where T : UIViewController {
            guard let controller = controller as? PickerConfigViewController else { return { _ in } }
            switch self {
            case .editorOptions:
                return controller.editorOptionsTapped
            case .saveEditedAsset:
                return controller.saveEditedAssetTapped
            }
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
        
        func getFunction<T>(_ controller: T) -> ((IndexPath) -> Void) where T : UIViewController {
            guard let controller = controller as? PickerConfigViewController else { return { _ in } }
            switch self {
            case .captureOptions:
                return controller.captureMediaOptionsTapped
            }
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
        
        func getFunction<T>(_ controller: T) -> ((IndexPath) -> Void) where T : UIViewController {
            guard let controller = controller as? PickerConfigViewController else { return { _ in } }
            switch self {
            case .fullScreen:
                return controller.fullScreenTapped
            }
        }
    }
}
