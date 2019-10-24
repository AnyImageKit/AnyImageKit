//
//  SplitViewController.swift
//  Example
//
//  Created by 刘栋 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible
    }
}
