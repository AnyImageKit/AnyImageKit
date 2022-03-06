//
//  AssetPlugin.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

open class AssetPlugin: IdentifiableResource {
    
    open var identifier: String {
        fatalError("You must create subclass and override identifier!")
    }
    
    open func register(_ context: RegisterContext) {
        fatalError("You must create subclass and override this function!")
    }
    
    open func dequeue(_ context: DequeueContext) -> UICollectionViewCell & PickerOptionsConfigurableContent {
        fatalError("You must create subclass and override this function!")
    }
    
    open func select(_ context: SelectContext) {
        fatalError("You must create subclass and override this function!")
    }
}

extension AssetPlugin {
    
    public struct RegisterContext {
        public let collectionView: UICollectionView
    }
    
    public struct DequeueContext {
        public let collectionView: UICollectionView
        public let indexPath: IndexPath
    }
    
    public struct SelectContext {
        public let collectionView: UICollectionView
        public let controller: UIViewController & PickerOptionsConfigurableContent
    }
}
