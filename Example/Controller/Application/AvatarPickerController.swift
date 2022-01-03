//
//  AvatarPickerController.swift
//  Example
//
//  Created by Ray on 2020/6/8.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
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
        options.selectionTapAction = .openEditor
        options.saveEditedAsset = false
        options.editorOptions = [.photo]
        options.editorPhotoOptions.toolOptions = [.crop]
        options.editorPhotoOptions.cropOptions = [.custom(w: 1, h: 1)]
        let controller = ImagePickerController(options: options, delegate: self)
        controller.modalPresentationStyle = .fullScreen
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
        picker.dismiss(animated: true, completion: nil)
        let controller = EditorResultViewController()
        controller.imageView.image = result.assets.first!.image
        show(controller, sender: nil)
    }
}

// MARK: - Enum
extension AvatarPickerController {
    
    // MARK: - Section
    enum Section: Int, CaseIterable {
        case pickerConfig = 0
        
        var title: String {
            switch self {
            case .pickerConfig:
                return "Picker config"
            }
        }
        
        var allRowCase: [RowTypeRule] {
            switch self {
            case .pickerConfig:
                return PickerConfigRowType.allCases
            }
        }
    }
    
    // MARK: - Picker Config
    enum PickerConfigRowType: Int, CaseIterable, RowTypeRule {
        case selectLimit = 0
        case selectionTapAction
        case editorOptions
        case saveEditedAsset
        case editorPhotoOptions_editOptions
        case editorPhotoOptions_cropOptions
        
        var title: String {
            switch self {
            case .selectLimit:
                return "SelectLimit"
            case .selectionTapAction:
                return "SelectionTapAction"
            case .saveEditedAsset:
                return "SaveEditedAsset"
            case .editorOptions:
                return "EditorOptions"
            case .editorPhotoOptions_editOptions:
                return "EditOptions"
            case .editorPhotoOptions_cropOptions:
                return "CropOptions"
            }
        }
        
        var options: String {
            switch self {
            case .selectLimit:
                return ".selectLimit"
            case .selectionTapAction:
                return ".selectionTapAction"
            case .saveEditedAsset:
                return ".saveEditedAsset"
            case .editorOptions:
                return ".editorOptions"
            case .editorPhotoOptions_editOptions:
                return ".editorPhotoOptions.editOptions"
            case .editorPhotoOptions_cropOptions:
                return ".editorPhotoOptions.cropOptions"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .selectLimit:
                return "1"
            case .selectionTapAction:
                return "OpenEditor"
            case .saveEditedAsset:
                return "false"
            case .editorOptions:
                return "Photo"
            case .editorPhotoOptions_editOptions:
                return "Crop"
            case .editorPhotoOptions_cropOptions:
                return "1:1"
            }
        }
    }
}
