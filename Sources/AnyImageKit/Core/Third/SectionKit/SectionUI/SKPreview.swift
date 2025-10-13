//
//  SKPreview.swift
//  SectionKit
//
//  Created by linhey on 1/13/25.
//

import UIKit
import SwiftUI

public struct SKPreview {
    
    public static func sections(_ model: @escaping () -> [SKCSectionProtocol]) -> some View {
        SKUIController {
            SKCollectionViewController()
                .reloadSections(model())
        }
    }
    
    public static func sections(_ model: @escaping () -> SKCSectionProtocol) -> some View {
        self.sections { [model()] }
    }
    
}
