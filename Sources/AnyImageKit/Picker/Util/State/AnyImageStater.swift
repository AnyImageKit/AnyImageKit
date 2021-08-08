//
//  AnyImageStater.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

final class AnyImageStater<Resource: FetchableResource> {
    
    private var stateStroage: [String: ResourceState<Resource>] = [:]
    private var selectedStroage: [String] = []
     
    var disableCheckRules: [AnyResourceDisableCheckRule<Resource>] = []
    
    func loadState(key: String) -> ResourceState<Resource> {
        return stateStroage[key] ?? .initialize
    }
    
    func updateState(_ state: ResourceState<Resource>, key: String) {
        if let index = selectedStroage.firstIndex(of: key), state != .selected {
            selectedStroage.remove(at: index)
        } else if state == .selected {
            selectedStroage.append(key)
        }
        stateStroage[key] = state
    }
    
    func selectedIndex(key: String) -> Int? {
        return selectedStroage.firstIndex(of: key)
    }
}
