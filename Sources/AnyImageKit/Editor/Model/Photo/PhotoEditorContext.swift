//
//  PhotoEditorContext.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/30.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

final class PhotoEditorContext {
    
    var toolOption: EditorPhotoToolOption?
    
    let options: EditorPhotoOptionsInfo
    
    private var didReceiveAction: ((PhotoEditorAction) -> Bool)?
    
    init(options: EditorPhotoOptionsInfo) {
        self.options = options
    }
}

extension PhotoEditorContext {
    
    func didReceiveAction(_ callback: @escaping ((PhotoEditorAction) -> Bool)) {
        if didReceiveAction == nil {
            didReceiveAction = callback
        }
    }
    
    @discardableResult
    func action(_ action: PhotoEditorAction) -> Bool {
        return didReceiveAction?(action) ?? false
    }
}
