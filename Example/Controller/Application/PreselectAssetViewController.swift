//
//  PreselectAssetViewController.swift
//  Example
//
//  Created by 蒋惠 on 2020/10/20.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class PreselectAssetViewController: UIViewController {

    private var assets: [Asset] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PickerPreviewCell.self, forCellWithReuseIdentifier: "PreviewCell")
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        view.dataSource = self
        view.delegate = self
        return view
    }()
    private(set) lazy var tipsLabel: UILabel = {
        let view = UILabel()
        view.text = Bundle.main.localizedString(forKey: "Preselect Assets Tips", value: nil, table: nil)
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preselect Asset"
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        view.addSubview(tipsLabel)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        tipsLabel.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setupNavigation() {
        let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(openPickerTapped))
    }
}

// MARK: - Target
extension PreselectAssetViewController {
    
    @objc private func openPickerTapped() {
        var options = PickerOptionsInfo()
        options.editorOptions = [.photo]
        options.preselectAssets = assets.map { $0.identifier }
        let controller = ImagePickerController(options: options, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - ImagePickerControllerDelegate
extension PreselectAssetViewController: ImagePickerControllerDelegate {
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        print(result.assets)
        assets = result.assets
        collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension PreselectAssetViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tipsLabel.isHidden = !assets.isEmpty
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! PickerPreviewCell
        cell.imageView.image = assets[indexPath.item].image
        cell.titleLabel.text = assets[indexPath.item].mediaType.description
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PreselectAssetViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete asset", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.assets.remove(at: indexPath.item)
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PreselectAssetViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.bounds.width - 20 - 10*2)/3)
        return CGSize(width: width, height: width)
    }
}
