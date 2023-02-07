//
//  File.swift
//
//
//  Created by linhey on 2022/5/5.
//

import Foundation
import UIKit

public extension SKCollectionFlowLayout.BindingKey where Value == Int {
    
    convenience init(_ section: SKCSectionActionProtocol) {
        self.init(get: { [weak section] in
            guard let section = section, let injection = section.sectionInjection else {
                return nil
            }
            return injection.index
        })
    }
    
}

public extension SKCollectionFlowLayout.Decoration {
    
    init(_ section: SKCSectionActionProtocol,
         viewType: SKCollectionFlowLayout.DecorationView.Type,
         zIndex: Int = -1,
         layout: [SKCollectionFlowLayout.DecorationLayout] = [.header, .cells, .footer],
         insets: UIEdgeInsets = .zero) {
        self.init(sectionIndex: .init(section),
                  viewType: viewType,
                  zIndex: zIndex,
                  layout: layout,
                  insets: insets)
    }
    
}
