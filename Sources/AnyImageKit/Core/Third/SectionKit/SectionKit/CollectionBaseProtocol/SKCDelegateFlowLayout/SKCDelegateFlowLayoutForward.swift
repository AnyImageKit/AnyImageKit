//
//  File.swift
//
//
//  Created by linhey on 2024/3/14.
//

import Foundation
import UIKit

public class SKCDelegateFlowLayoutForward: SKCDelegateForward, UICollectionViewDelegateFlowLayout {
    
    var flowLayoutForwards: [SKCDelegateFlowLayoutForwardProtocol] = []
    var flowLayoutObservers: [SKCDelegateFlowLayoutObserverProtocol] = []
    
}

public extension SKCDelegateFlowLayoutForward {

    func add(flowLayout item: SKCDelegateFlowLayoutObserverProtocol) {
        flowLayoutObservers.append(item)
    }
    
    func add(flowLayout item: SKCDelegateFlowLayoutForwardProtocol) {
        flowLayoutForwards.append(item)
    }
    
    func add(_ item: SKCDelegateFlowLayoutObserverProtocol) {
        add(flowLayout: item)
    }
    
    func add(_ item: SKCDelegateFlowLayoutForwardProtocol) {
        add(flowLayout: item)
    }
    
    func find<T>(`default`: T, _ task: (_ item: SKCDelegateFlowLayoutForwardProtocol) -> SKHandleResult<T>) -> T {
        for item in flowLayoutForwards.reversed() {
            let result = task(item)
            switch result {
            case .handle(let value):
                return value
            case .next:
                break
            }
        }
        return `default`
    }
    
    func observe(_ task: (_ item: SKCDelegateFlowLayoutObserverProtocol) -> Void) {
        flowLayoutObservers.forEach(task)
    }
    
}

public extension SKCDelegateFlowLayoutForward {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let value = find(default: .zero) { $0.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, value: value) }
        return value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let value = find(default: .zero) { $0.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section, value: value) }
        return value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let value = find(default: 0) { $0.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section, value: value) }
        return value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let value = find(default: 0) { $0.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section, value: value) }
        return value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let value = find(default: .zero) { $0.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section, value: value) }
        return value
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let value = find(default: .zero) { $0.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) }
        observe { $0.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section, value: value) }
        return value
    }
    
}
