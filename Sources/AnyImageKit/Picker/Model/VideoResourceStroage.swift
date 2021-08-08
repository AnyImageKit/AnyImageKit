//
//  VideoResourceStroage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/8/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import AVFoundation
import AVKit

public typealias VideoResourceLoadCompletion = (Result<VideoResourceStorage, Error>) -> Void

public enum VideoResourceStorage {
    
    case playback(AVAsset)
    case export
}
