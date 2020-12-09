//
//  DisableCheckRuleViewController.swift
//  Example
//
//  Created by 刘栋 on 2020/11/29.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class DisableCheckRuleViewController: UITableViewController {
    
    var enableVideoDurationCheck: Bool = true
    var videoDuration: VideoDurationDisableCheckRule = .init(min: 3, max: 120)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Disable Check Rule"
        let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
    
    private func setupView() {
        tableView.register(EnableCell.self, forCellReuseIdentifier: EnableCell.reuseIdentifier)
        tableView.register(ConfigCell.self, forCellReuseIdentifier: ConfigCell.reuseIdentifier)
    }
    
    @objc private func openPickerTapped() {
        var options = PickerOptionsInfo()
        options.disableRules = [videoDuration]
        let controller = ImagePickerController(options: options, delegate: self)
        present(controller, animated: true, completion: nil)
    }
}

extension DisableCheckRuleViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section.allCases[section]
        switch sectionType {
        case .videoDuration:
            return VideoDurationRow.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = Section.allCases[indexPath.section]
        switch sectionType {
        case .videoDuration:
            let rowType = VideoDurationRow.allCases[indexPath.row]
            switch rowType {
            case .enableCheck:
                let cell = tableView.dequeueReusableCell(withIdentifier: EnableCell.reuseIdentifier, for: indexPath) as! EnableCell
                cell.titleLabel.text = "Enable"
                cell.enableSwitch.isOn = enableVideoDurationCheck
                cell.enableSwitch.addTarget(self, action: #selector(switchEnableVideoDurationCheck(_:)), for: .valueChanged)
                return cell
            case .minDuration:
                let cell = tableView.dequeueReusableCell(withIdentifier: ConfigCell.reuseIdentifier, for: indexPath) as! ConfigCell
                cell.titleLabel.text = "Min value"
                cell.tagsButton.setTitle(".minDuration", for: .normal)
                cell.contentLabel.text = videoDuration.minDuration.description
                return cell
            case .maxDuration:
                let cell = tableView.dequeueReusableCell(withIdentifier: ConfigCell.reuseIdentifier, for: indexPath) as! ConfigCell
                cell.titleLabel.text = "Max value"
                cell.tagsButton.setTitle(".maxDuration", for: .normal)
                cell.contentLabel.text = videoDuration.maxDuration.description
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = Section.allCases[section]
        return sectionType.title
    }
}

extension DisableCheckRuleViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DisableCheckRuleViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        print(result.assets)
        let controller = PickerResultViewController()
        controller.assets = result.assets
        show(controller, sender: nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Sections
extension DisableCheckRuleViewController {
    
    private enum Section: CaseIterable {
        
        case videoDuration
        
        var title: String {
            switch self {
            case .videoDuration:
                return "Video Duration"
            }
        }
    }
}

// MARK: - Rows VideoDuration
extension DisableCheckRuleViewController {
    
    @objc private func switchEnableVideoDurationCheck(_ sender: UISwitch) {
        self.enableVideoDurationCheck = sender.isOn
    }
     
    private enum VideoDurationRow: CaseIterable {
        
        case enableCheck
        case minDuration
        case maxDuration
    }
}
