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
        print("Start")
        
        let vc = TestViewController()
//        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = TestViewController()
//        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

