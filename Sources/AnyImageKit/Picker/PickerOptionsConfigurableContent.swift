//
//  PickerOptionsConfigurableContent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/3/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Combine

public class PickerOptionsConfigurableContext {
    
    let subject: CurrentValueSubject<PickerOptionsInfo, Never>
    
    public init() {
        self.subject = .init(.init())
    }
}

extension PickerOptionsConfigurableContext {
    
    public var publisher: AnyPublisher<PickerOptionsInfo, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public var options: PickerOptionsInfo {
        get { subject.value }
        set { subject.send(newValue) }
    }
}

public protocol PickerOptionsConfigurableContent: AnyObject {
    
    var context: PickerOptionsConfigurableContext { get }
    func update(options: PickerOptionsInfo)
}

extension PickerOptionsConfigurableContent {
    
    var options: PickerOptionsInfo {
        get { context.options }
        set { context.options = newValue }
    }
}

extension PickerOptionsConfigurableContent {
    
    public func assign(on content: PickerOptionsConfigurableContent) -> AnyCancellable {
        context.subject.assign(to: \.options, on: content)
    }
    
    public func sink() -> AnyCancellable {
        context.publisher.sink { [weak self] newOptions in
            guard let self = self else { return }
            self.update(options: newOptions)
        }
    }
}
