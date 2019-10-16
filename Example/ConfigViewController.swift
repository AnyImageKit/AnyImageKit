//
//  ConfigViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/10/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import AnyImagePicker

final class ConfigViewController: UITableViewController {

    var config = ImagePickerController.Config()
    
    // MARK: - Action
    
    @IBAction func pickButtonTapped(_ sender: UIBarButtonItem) {
        let controller = ImagePickerController(config: config, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType(rawValue: indexPath.row)!
        switch rowType {
        case .theme:
            themeTapped()
        case .maxCount:
            maxCountTapped()
        case .columnNumber:
            columnNumberTapped()
        case .allowUseOriginalPhoto:
            allowUseOriginalPhotoTapped()
        case .selectOptions:
            selectOptionsTapped()
        case .orderbyDate:
            orderbyDateTapped()
        }
    }
}

extension ConfigViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didSelect assets: [Asset], isOriginal: Bool) {
        
    }
    
}

extension ConfigViewController {
    
    private func themeTapped() {
        let indexPath = RowType.theme.indexPath
        let alert = UIAlertController(title: "Theme", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Auto", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .wechat(style: .auto)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Auto"
        }))
        alert.addAction(UIAlertAction(title: "Light", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .wechat(style: .light)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Light"
        }))
        alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { [weak self] (_) in
            self?.config.theme = .wechat(style: .dark)
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Dark"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func maxCountTapped() {
        let indexPath = RowType.maxCount.indexPath
        let alert = UIAlertController(title: "MaxCount", message: nil, preferredStyle: .alert)
        for i in 3...9 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { [weak self] (_) in
                self?.config.maxCount = i
                self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(i)"
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func columnNumberTapped() {
        let indexPath = RowType.columnNumber.indexPath
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
    
    private func allowUseOriginalPhotoTapped() {
        let indexPath = RowType.allowUseOriginalPhoto.indexPath
        config.allowUseOriginalPhoto.toggle()
        tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "\(config.allowUseOriginalPhoto)"
    }
    
    private func selectOptionsTapped() {
        let indexPath = RowType.selectOptions.indexPath
        let alert = UIAlertController(title: "SelectOptions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo+Video", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photo, .video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo+Video"
        }))
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.photo]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Photo"
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] (_) in
            self?.config.selectOptions = [.video]
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Video"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func orderbyDateTapped() {
        let indexPath = RowType.orderbyDate.indexPath
        let alert = UIAlertController(title: "OrderbyDate", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Asc", style: .default, handler: { [weak self] (_) in
            self?.config.orderByDate = .asc
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Asc"
        }))
        alert.addAction(UIAlertAction(title: "Desc", style: .default, handler: { [weak self] (_) in
            self?.config.orderByDate = .desc
            self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Desc"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

enum RowType: Int {
    case theme = 0
    case maxCount
    case columnNumber
    case allowUseOriginalPhoto
    case selectOptions
    case orderbyDate
    
    var indexPath: IndexPath {
        return IndexPath(row: rawValue, section: 0)
    }
}
