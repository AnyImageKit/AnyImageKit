//
//  ViewController.swift
//  Example
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import AnyImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(111)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = TestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

