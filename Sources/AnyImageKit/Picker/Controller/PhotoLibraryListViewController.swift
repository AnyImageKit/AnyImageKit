//
//  PhotoLibraryListViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

private let rowHeight: CGFloat = 55

final class PhotoLibraryListViewController: AnyImageViewController, PickerOptionsConfigurableContent {
    
    private lazy var tableView: UITableView = makeTableView()
    
    private var photoLibrary: PhotoLibraryAssetCollection?
    private var photoLibraryList: [PhotoLibraryAssetCollection] = []
    private var continuation: CheckedContinuation<UserAction<PhotoLibraryAssetCollection>, Never>?
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    
    deinit {
        removeNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        updatePreferredContentSize(with: traitCollection)
        setupView()
        setupDataBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resume(result: .cancel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrentPhotoLibrary()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: PickerOptionsConfigurableContent
extension PhotoLibraryListViewController {
    
    func update(options: PickerOptionsInfo) {
        tableView.backgroundColor = options.theme[color: .background]
    }
}

// MARK:
extension PhotoLibraryListViewController {
    
    func config(library: PhotoLibraryAssetCollection?, libraryList: [PhotoLibraryAssetCollection]) {
        photoLibrary = library
        photoLibraryList = libraryList
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    func pick() async -> UserAction<PhotoLibraryAssetCollection> {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    private func resume(result: UserAction<PhotoLibraryAssetCollection>) {
        if let continuation = continuation {
            continuation.resume(returning: result)
            self.continuation = nil
        }
    }
}

// MARK: - Target
extension PhotoLibraryListViewController {
    
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
extension PhotoLibraryListViewController {
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChangeNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func scrollToCurrentPhotoLibrary() {
        if let photoLibrary = photoLibrary, let index = photoLibraryList.firstIndex(of: photoLibrary) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    private func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let screenSize = ScreenHelper.mainBounds.size
        let preferredMinHeight = rowHeight * 5
        let preferredMaxHeight = floor(screenSize.height*(2.0/3.0))
        let presentingViewController = (self.presentingViewController as? ImagePickerController)?.topViewController
        let preferredWidth = presentingViewController?.view.bounds.size.width ?? screenSize.width
        if photoLibraryList.isEmpty {
            preferredContentSize = CGSize(width: preferredWidth, height: preferredMaxHeight)
        } else {
            let height = CGFloat(photoLibraryList.count) * rowHeight
            let preferredHeight = max(preferredMinHeight, min(height, preferredMaxHeight))
            preferredContentSize = CGSize(width: preferredWidth, height: preferredHeight)
        }
    }
}

// MARK: - UI
extension PhotoLibraryListViewController {
    
    private func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(view.snp.edges)
        }
    }
    
    private func setupDataBinding() {
        sink().store(in: &cancellables)
    }
    
    private func makeTableView() -> UITableView {
        let view = UITableView(frame: .zero, style: .plain)
        view.registerCell(PhotoLibraryCell.self)
        view.separatorStyle = .none
        view.dataSource = self
        view.delegate = self
        return view
    }
}

// MARK: - UITableViewDataSource
extension PhotoLibraryListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoLibraryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PhotoLibraryCell.self, for: indexPath)
        let photoLibrary = photoLibraryList[indexPath.row]
        cell.setContent(photoLibrary)
        listCancellables[indexPath] = assign(on: cell)
        cell.accessoryType = self.photoLibrary == photoLibrary ? .checkmark : .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PhotoLibraryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let photoLibrary = photoLibraryList[indexPath.row]
        if photoLibrary != self.photoLibrary {
            resume(result: .interaction(photoLibrary))
        } else {
            resume(result: .cancel)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}
