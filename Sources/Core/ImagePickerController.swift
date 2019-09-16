//
//  ImagePickerController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

public protocol ImagePickerControllerDelegate: class {
    
    func imagePicker(_ picker: ImagePickerController)
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    
    
    
}
