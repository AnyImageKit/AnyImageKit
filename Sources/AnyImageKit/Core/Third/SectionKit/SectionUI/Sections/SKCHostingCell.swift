//
//  File.swift
//
//
//  Created by linhey on 2023/12/29.
//

import UIKit
import SwiftUI

@available(iOS 16.0, *)
public extension SKExistModelProtocol where Self: View {
    
    static func wrapperToCollectionCell() -> STCHostingCell<Self>.Type {
        return STCHostingCell<Self>.self
    }
    
    static func wrapperToCollectionReusableView() -> STCHostingCell<Self>.Type {
        return STCHostingCell<Self>.self
    }
    
}

@available(iOS 16.0, *)
public final class STCHostingCell<ContentView: SKExistModelProtocol & View>: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAutoAdaptiveView {
    
    public typealias Model = ContentView.Model
    private let store = STCHostingCellContentReducer<ContentView.Model>()
    private var wrappedView: UIView = .init()
    
    public func config(_ model: ContentView.Model) {
        store.model = model
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
            initialize()
    }
    
    public func initialize() {
        contentConfiguration = UIHostingConfiguration {
            STCHostingCellContentView<ContentView>(store: store)
        }
        .margins(.all, 0)
    }
    
}

final class STCHostingCellContentReducer<Model>: ObservableObject {
    @Published var model: Model?
}

struct STCHostingCellContentView<ContentView: SKExistModelProtocol & View>: View {
    
    @ObservedObject var store: STCHostingCellContentReducer<ContentView.Model>
    
    var body: some View {
        if let model = store.model {
            ContentView(model: model)
        } else {
            EmptyView()
        }
    }
    
}
