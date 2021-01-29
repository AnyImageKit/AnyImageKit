//
//  PhotoEditorContext.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/30.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

final class PhotoEditorContext {
    
    var toolOption: EditorPhotoToolOption?
    
    let options: EditorPhotoOptionsInfo
    
    private var didReceiveAction: ((PhotoEditorAction) -> Void)?
    
    init(options: EditorPhotoOptionsInfo) {
        self.options = options
    }
}

extension PhotoEditorContext {
    
    func didReceiveAction(_ callback: @escaping ((PhotoEditorAction) -> Void)) {
        if didReceiveAction == nil {
            didReceiveAction = callback
        }
    }
    
    func action(_ action: PhotoEditorAction) {
        didReceiveAction?(action)
    }
}
