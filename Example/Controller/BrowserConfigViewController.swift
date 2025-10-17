
//
//  BrowserConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2025/10/14.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import AnyImageKit
import Kingfisher

final class BrowserConfigViewController: UITableViewController {
    
    var options = BrowserOptionsInfo()
    
    private var resourceType: ResourceType = .remote
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }
    
    private func setupNavigation() {
        navigationItem.title = "Browser"
        let title = Bundle.main.localizedString(forKey: "OpenBrowser", value: "Open", table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openBrowserTapped))
    }
    
    private func setupView() {
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(ConfigCell.self, forCellReuseIdentifier: ConfigCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Target
    
    @objc private func openBrowserTapped() {
        switch resourceType {
        case .image:
            let resources: [UIImage?] = [
                UIImage(named: "TitleMapPicker"),
                UIImage(named: "TitleMapEditor"),
                UIImage(named: "TitleMapCapture"),
            ]
            options.resources = resources.map { .image($0!) }
        case .remote:
            let resources: [BrowserResource] = [
                .remoteVideo(url: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4")!, thumbnailURL: nil),
                .remoteImage(URL(string: "https://picsum.photos/1600/1200")!),
                .remoteImage(URL(string: "https://picsum.photos/1200/1600")!),
            ]
            options.resources = resources
        case .localURL:
            let resources: [URL] = [
                Bundle.main.url(forResource: "EditorTestVideo", withExtension: "mp4")!
            ]
            options.resources = resources.map { .localFile($0) }
        }
        
        let controller = BrowserController(options: options)
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

// MARK: - Tapped
extension BrowserConfigViewController {
    
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
    
    private func resourceTapped(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Resource", message: nil, preferredStyle: .alert)
        for type in ResourceType.allCases {
            alert.addAction(UIAlertAction(title: type.title, style: .default, handler: { [weak self] (action) in
                self?.resourceType = type
                (self?.tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = action.title
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showStatusBarTapped(_ indexPath: IndexPath) {
        options.showStatusBar = !options.showStatusBar
        (tableView.cellForRow(at: indexPath) as? ConfigCell)?.contentLabel.text = "\(options.showStatusBar)"
    }
}

// MARK: - Enum
extension BrowserConfigViewController {
    
    // MARK: - Section
    enum Section: Int, CaseIterable {
        case config
        
        var title: String? {
            switch self {
            case .config:
                return "Options"
            }
        }
        
        var allRowCase: [RowTypeRule] {
            switch self {
            case .config:
                return ConfigRowType.allCases
            }
        }
    }
    
    // MARK: - Config
    enum ConfigRowType: Int, CaseIterable, RowTypeRule {
        case theme = 0
        case resource
        case showStatusBar
        
        var title: String {
            switch self {
            case .theme:
                return "Theme"
            case .resource:
                return "ResourceType"
            case .showStatusBar:
                return "ShowStatusBar"
            }
        }
        
        var options: String {
            switch self {
            case .theme:
                return ".theme"
            case .resource:
                return ".resources"
            case .showStatusBar:
                return ".showStatusBar"
            }
        }
        
        var defaultValue: String {
            switch self {
            case .theme:
                return "Auto"
            case .resource:
                return "Image and Video URL"
            case .showStatusBar:
                return "true"
            }
        }

        func getFunction<T: UIViewController>(_ controller: T) -> ((IndexPath) -> Void) {
            guard let controller = controller as? BrowserConfigViewController else { return { _ in } }
            switch self {
            case .theme:
                return controller.themeTapped
            case .resource:
                return controller.resourceTapped
            case .showStatusBar:
                return controller.showStatusBarTapped
            }
        }
    }
    
    enum ResourceType: Int, CaseIterable {
        case image
        case remote
        case localURL
        
        var title: String {
            switch self {
            case .image:
                return "UIImage"
            case .remote:
                return "Image and Video URL"
            case .localURL:
                return "Local URL"
            }
        }
    }
}
