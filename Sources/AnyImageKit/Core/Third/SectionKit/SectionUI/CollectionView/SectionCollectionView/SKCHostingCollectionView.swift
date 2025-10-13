//
//  SKHostingCollectionView.swift
//  CoolUp
//
//  Created by linhey on 11/15/24.
//

import Foundation
import SwiftUI

public struct SKCHostingCollectionView: UIViewControllerRepresentable {
   
    public typealias UIViewControllerType = SKCollectionViewController
    
    public class Coordinator {
        
        public var manager: SKCManager?
        public var sections: [SKCAnySectionProtocol]
        
        init(manager: SKCManager? = nil, sections: [SKCAnySectionProtocol]) {
            self.manager = manager
            self.sections = sections
        }
    }
        
    let sections: [any SKCAnySectionProtocol]
    
    public init(_ sections: [any SKCAnySectionProtocol]) {
        self.sections = sections
    }
    
    public init(_ sections: () -> [any SKCAnySectionProtocol]) {
        self.sections = sections()
    }
    
    public init(@SectionArrayResultBuilder<SKCAnySectionProtocol> builder: () -> [SKCAnySectionProtocol]) {
        self.sections = builder()
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(manager: nil, sections: sections)
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let controller = SKCollectionViewController()
        controller.view.backgroundColor = .clear
        controller.sectionView.backgroundColor = .clear
        context.coordinator.manager = controller.manager
        context.coordinator.manager?.reload(context.coordinator.sections.map(\.section))
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: SKCollectionViewController, context: Context) {
        if sections.map(\.objectIdentifier) != context.coordinator.sections.map(\.objectIdentifier) {
            context.coordinator.sections = sections
            context.coordinator.manager?.reload(context.coordinator.sections.map(\.section))
        }
    }
}
