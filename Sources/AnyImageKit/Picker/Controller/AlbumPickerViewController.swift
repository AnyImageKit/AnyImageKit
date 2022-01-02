//
//  AlbumPickerViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

private let rowHeight: CGFloat = 55

protocol AlbumPickerViewControllerDelegate: AnyObject {
    
    func albumPicker(_ picker: AlbumPickerViewController, didSelected album: Album)
    func albumPickerWillDisappear(_ picker: AlbumPickerViewController)
}

final class AlbumPickerViewController: AnyImageViewController {
    
    weak var delegate: AlbumPickerViewControllerDelegate?
    var album: Album?
    var albums = [Album]()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.registerCell(AlbumCell.self)
        view.separatorStyle = .none
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    let manager: PickerManager
    
    init(manager: PickerManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        updatePreferredContentSize(with: traitCollection)
        setupView()
        update(options: manager.options)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.albumPickerWillDisappear(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToCurrentAlbum()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - Target
extension AlbumPickerViewController {
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func orientationDidChangeNotification(_ sender: Notification) {
        // TODO: Fix orientation change
        if UIDevice.current.userInterfaceIdiom == .pad {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Private
extension AlbumPickerViewController {
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChangeNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(view.snp.edges)
        }
    }
    
    private func scrollToCurrentAlbum() {
        if let album = album, let index = albums.firstIndex(of: album) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    private func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let screenSize = ScreenHelper.mainBounds.size
        let preferredMinHeight = rowHeight * 5
        let preferredMaxHeight = floor(screenSize.height*(2.0/3.0))
        let presentingViewController = (self.presentingViewController as? ImagePickerController)?.topViewController
        let preferredWidth = presentingViewController?.view.bounds.size.width ?? screenSize.width
        if albums.isEmpty {
            preferredContentSize = CGSize(width: preferredWidth, height: preferredMaxHeight)
        } else {
            let height = CGFloat(albums.count) * rowHeight
            let preferredHeight = max(preferredMinHeight, min(height, preferredMaxHeight))
            preferredContentSize = CGSize(width: preferredWidth, height: preferredHeight)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension AlbumPickerViewController: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        tableView.backgroundColor = options.theme[color: .background]
        updateChildrenConfigurable(options: options)
    }
}

// MARK: - UITableViewDataSource
extension AlbumPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AlbumCell.self, for: indexPath)
        let album = albums[indexPath.row]
        cell.setContent(album, manager: manager)
        cell.accessoryType = self.album == album ? .checkmark : .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AlbumPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        delegate?.albumPicker(self, didSelected: album)
        dismiss(animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}
