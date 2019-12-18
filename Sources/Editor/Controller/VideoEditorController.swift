//
//  VideoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol VideoEditorControllerDelegate: class {
    
    func videoEditorDidCancel(_ editor: VideoEditorController)
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool)
}

final class VideoEditorController: UIViewController {
    
    private let resource: VideoResource
    private let placeholdImage: UIImage?
    private let config: ImageEditorController.VideoConfig
    private weak var delegate: VideoEditorControllerDelegate?
    
    init(resource: VideoResource, placeholdImage: UIImage?, config: ImageEditorController.VideoConfig, delegate: VideoEditorControllerDelegate) {
        self.resource = resource
        self.placeholdImage = placeholdImage
        self.config = config
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
}
