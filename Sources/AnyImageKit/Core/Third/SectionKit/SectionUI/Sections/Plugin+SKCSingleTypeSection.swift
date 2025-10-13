//
//  Plugin+.swift
//  Pods
//
//  Created by linhey on 5/28/25.
//

import Foundation

extension SKCSingleTypeSection: SKCSectionLayoutPluginProtocol {
    
    public var plugins: [SKCSectionLayoutPlugin] {
        set { self.environment(of: newValue) }
        get { self.environment(of: [SKCSectionLayoutPlugin].self) ?? [] }
    }
    
}
