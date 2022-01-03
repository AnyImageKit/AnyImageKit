//
//  ImageKitDataTrackDelegate.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/16.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public protocol ImageKitDataTrackDelegate: AnyObject {
    
    func dataTrack(page: AnyImagePage, state: AnyImagePageState)
    func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any])
}

extension ImageKitDataTrackDelegate {
    
    func dataTrack(page: AnyImagePage, state: AnyImagePageState) { }
    func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any]) { }
}
