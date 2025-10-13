//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

#if canImport(UIKit)
import UIKit

public struct SKCDelegateFlowLayout: SKCDelegateFlowLayoutForwardProtocol {
    
    let dataSource: SKCManagerPublishers
    
    private func section(_ indexPath: IndexPath) -> SKCViewDelegateFlowLayoutProtocol? {
        return dataSource.safe(section: indexPath.section)
    }
}

public extension SKCDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> SKHandleResult<CGSize> {
        guard let section = self.section(indexPath) else {
            return .next
        }
        
        var size = section.itemSize(at: indexPath.item)
        
        if size.width < 0 || size.height < 0 {
            assertionFailure("Negative sizes are not supported in the flow layout, \(section)")
            size = .init(width: max(size.width, 0), height: max(size.height, 0))
        }
        
        if size == .zero {
            SKPrint.function("size is zero, \(indexPath)")
            size = .init(width: 0.01, height: 0.01)
        }
        
        return .handle(size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> SKHandleResult<UIEdgeInsets> {
        .handleable(self.section(.init(row: 0, section: section))?.sectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> SKHandleResult<CGFloat> {
        .handleable(self.section(.init(row: 0, section: section))?.minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> SKHandleResult<CGFloat> {
        .handleable(self.section(.init(row: 0, section: section))?.minimumInteritemSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> SKHandleResult<CGSize> {
        .handleable(self.section(.init(row: 0, section: section))?.headerSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> SKHandleResult<CGSize> {
        .handleable(self.section(.init(row: 0, section: section))?.footerSize)
    }
    
}

#endif
