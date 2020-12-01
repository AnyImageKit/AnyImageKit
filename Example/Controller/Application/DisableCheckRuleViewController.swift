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
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = Section.allCases[section]
        return sectionType.title
    }
}

extension DisableCheckRuleViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
     
    private enum VideoDurationRow: CaseIterable {
        
        case enableCheck
        case minDuration
        case maxDuration
    }
    
    private class VideoDurationCell: UITableViewCell {
        
        
    }
}
