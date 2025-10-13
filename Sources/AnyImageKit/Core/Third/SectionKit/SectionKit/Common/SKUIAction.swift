//
//  File.swift
//  
//
//  Created by linhey on 2024/2/26.
//

import UIKit

open class SKUIAction: UIAction {
    
    public typealias SKUIActionHandler = () async throws -> Void
    
    @MainActor
    public convenience init(title: String = "",
                            image: UIImage? = nil,
                            identifier: UIAction.Identifier? = nil,
                            discoverabilityTitle: String? = nil,
                            attributes: UIMenuElement.Attributes = [],
                            state: UIMenuElement.State = .off,
                            handler: @escaping SKUIActionHandler) {
        self.init(title: title,
                  image: image,
                  identifier: identifier,
                  discoverabilityTitle: discoverabilityTitle,
                  attributes: attributes,
                  state: state) { action in
            Task { @MainActor in
                try await handler()
            }
        }
    }
    
    @available(iOS 15.0, tvOS 15.0, *)
    @MainActor
    public convenience init(title: String = "",
                            subtitle: String? = nil,
                            image: UIImage? = nil,
                            identifier: UIAction.Identifier? = nil,
                            discoverabilityTitle: String? = nil,
                            attributes: UIMenuElement.Attributes = [],
                            state: UIMenuElement.State = .off,
                            handler: @escaping SKUIActionHandler) {
        self.init(title: title,
                  subtitle: subtitle,
                  image: image,
                  identifier: identifier,
                  discoverabilityTitle: discoverabilityTitle,
                  attributes: attributes,
                  state: state) { _ in
            Task { @MainActor in
                try await handler()
            }
        }
    }
    
    @available(iOS 17.0, tvOS 17.0, *)
    @MainActor
    public convenience init(title: String = "",
                            subtitle: String? = nil,
                            image: UIImage? = nil,
                            selectedImage: UIImage? = nil,
                            identifier: UIAction.Identifier? = nil,
                            discoverabilityTitle: String? = nil,
                            attributes: UIMenuElement.Attributes = [],
                            state: UIMenuElement.State = .off,
                            handler: @escaping SKUIActionHandler) {
        self.init(title: title,
                   subtitle: subtitle,
                   image: image,
                   selectedImage: selectedImage,
                   identifier: identifier,
                   discoverabilityTitle: discoverabilityTitle,
                   attributes: attributes,
                   state: state) { _ in
            Task { @MainActor in
                try await handler()
            }
        }
    }

}
