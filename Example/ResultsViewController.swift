//
//  ResultsViewController.swift
//  Example
//
//  Created by 刘栋 on 2019/10/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AnyImageKit

final class ResultsViewController: UIViewController {
    
    var assets: [Asset] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PreviewCell.self, forCellWithReuseIdentifier: "PreviewCell")
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

extension ResultsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! PreviewCell
        cell.imageView.image = assets[indexPath.item].image
        cell.titleLabel.text = assets[indexPath.item].mediaType.description
        return cell
    }
}

extension ResultsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        let alert = UIAlertController(title: "Detail", message: asset.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20 - 10*2)/3
        return CGSize(width: width, height: width)
    }
}

final class PreviewCell: UICollectionViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        view.textColor = .label
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { maker in
            maker.top.left.equalToSuperview().offset(4)
        }
    }
}
