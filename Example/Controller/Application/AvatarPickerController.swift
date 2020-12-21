//
//  AvatarPickerController.swift
//  Example
//
//  Created by Ray on 2020/6/8.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class AvatarPickerController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Avatar Picker"
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(ConfigCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setupNavigation() {
        let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    // MARK: - Target
    
    @IBAction func openPickerTapped() {
        var options = PickerOptionsInfo()
        options.selectLimit = 1
        options.quickPick = true
        let controller = ImagePickerController(options: options, delegate: self)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section(rawValue: section)!
        return sectionType.allRowCase.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = Section(rawValue: indexPath.section)!
        let rowType = sectionType.allRowCase[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConfigCell
        cell.setupData(rowType)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - ImagePickerControllerDelegate
extension AvatarPickerController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        var options = EditorPhotoOptionsInfo()
        options.toolOptions = [.crop]
        options.cropOptions = [.custom(w: 1, h: 1)]
        let editor = ImageEditorController(photo: result.assets.first!.image, options: options, delegate: self)
        picker.present(editor, animated: false, completion: nil)
    }
}

// MARK: - ImageEditorPhotoDelegate
extension AvatarPickerController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        openPickerTapped()
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        if result.type == .photo {
            guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
            guard let photo = UIImage(data: photoData) else { return }
            let controller = EditorResultViewController()
            controller.imageView.image = photo
            show(controller, sender: nil)
            editor.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - Enum
extension AvatarPickerController {
    
    // MARK: - Section
    enum Section: Int, CaseIterable {
        case pickerConfig = 0
        case editorConfig
        
        var title: String {
            switch self {
            case .pickerConfig:
                return "Picker config"
            case .editorConfig:
                return "Editor config"
            }
        }
        
        var allRowCase: [RowTypeRule] {
            switch self {
            case .pickerConfig:
                return PickerConfigRowType.allCases
            case .editorConfig:
                return EditorConfigRowType.allCases
            }
        }
    }
    
    // MARK: - Picker Config
    enum PickerConfigRowType: Int, CaseIterable, RowTypeRule {
        case selectLimit = 0
        case quickPick
        
        var title: String {
            switch self {
            case .selectLimit:
                return "SelectLimit"
            case .quickPick:
                return "QuickPick"
            }
        }
        
        var options: String {
            switch self {
            case .selectLimit:
                return ".selectLimit"
            case .quickPick:
                return ".quickPick"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .selectLimit:
                return "1"
            case .quickPick:
                return "true"
            }
        }
    }
    
    // MARK: - Editor Config
    enum EditorConfigRowType: Int, CaseIterable, RowTypeRule {
        case editOptions = 0
        case cropOptions
        
        var title: String {
            switch self {
            case .editOptions:
                return "EditOptions"
            case .cropOptions:
                return "CropOptions"
            }
        }
        
        var options: String {
            switch self {
            case .editOptions:
                return ".editOptions"
            case .cropOptions:
                return ".cropOptions"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .editOptions:
                return "Crop"
            case .cropOptions:
                return "1:1"
            }
        }
    }
}
