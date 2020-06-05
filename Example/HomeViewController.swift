//
//  HomeViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class HomeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "AnyImageKit"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RowType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let rowType = RowType.allCases[indexPath.row]
        cell.textLabel?.text = rowType.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType.allCases[indexPath.row]
        let controller: UIViewController
        let style: UITableView.Style
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        } else {
            style = .grouped
        }
        switch rowType {
        case .picker:
            controller = PickerConfigViewController(style: style)
        case .editor:
            controller = EditorConfigViewController(style: style)
        case .capture:
            controller = CaptureConfigViewController(style: style)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Module"
    }
}

extension HomeViewController {
    
    enum RowType: CaseIterable {
        case picker
        case editor
        case capture
        
        var title: String {
            switch self {
            case .picker:
                return "Picker"
            case .editor:
                return "Editor"
            case .capture:
                return "Capture"
            }
        }
    }
}
