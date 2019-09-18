//
//  AlbumPickerViewController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class AlbumPickerViewController: UIViewController {
    
    private var albums = [Album]()
    
    private(set) lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.registerCell(AlbumCell.self)
        view.separatorStyle = .none
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadAlbumsIfNeeded()
    }
}

// MARK: - Action

extension AlbumPickerViewController {
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Private

extension AlbumPickerViewController {
    
    private func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(view.snp.edges)
        }
    }
    
    private func loadAlbumsIfNeeded() {
        guard albums.isEmpty else { return }
        PhotoManager.shared.fetchAllAlbums(allowPickingVideo: true, allowPickingImage: true, needFetchAssets: false) { [weak self] fetchedAlbums in
            guard let self = self else { return }
            self.albums = fetchedAlbums
            self.tableView.reloadData()
        }
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
        cell.setContent(album)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        // TODO
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
