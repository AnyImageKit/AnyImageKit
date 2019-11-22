//
//  DebugHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/21.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

func _print(_ message: Any, _ file: String = #file, _ line: Int = #line) {
    #if DEBUG
//    if PickerManager.shared.config.enableDebugLog {
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)] \(message)")
//    }
    #endif
}
