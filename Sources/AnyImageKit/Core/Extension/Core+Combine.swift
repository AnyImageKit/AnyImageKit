//
//  Core+Combine.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Combine

extension Publisher {

    public func sink<T: AnyObject>(on target: T, receiveCompletion: @escaping ((T, Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((T, Self.Output) -> Void)) -> AnyCancellable {
        return self.sink { [weak target] error in
            guard let target = target else { return }
            receiveCompletion(target, error)
        } receiveValue: { [weak target] value in
            guard let target = target else { return }
            receiveValue(target, value)
        }
    }
}

extension Publisher where Self.Failure == Never {

    public func sink<T: AnyObject>(on target: T, receiveValue: @escaping ((T, Self.Output) -> Void)) -> AnyCancellable {
        return self.sink { [weak target] value in
            guard let target = target else { return }
            receiveValue(target, value)
        }
    }
}
