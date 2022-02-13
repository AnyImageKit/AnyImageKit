//
//  AssetDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

open class AssetDisableCheckRule<Resource: IdentifiableResource>: IdentifiableResource {
    
    open var identifier: String {
        fatalError("You must create subclass and override identifier!")
    }

    open func isDisable(for asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> Bool {
        fatalError("You must create subclass and override this function!")
    }
    
    open func disabledMessage(for asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> String {
        fatalError("You must create subclass and override this function!")
    }
}
