// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Combine
import Foundation

public class SKSelectionState: Equatable, Hashable, Identifiable {
    
    public let id: UUID = .init()
    // 返回一个 AnyPublisher，用于订阅选中状态、选择能力、可用性的变化
    public var changedPublisher: AnyPublisher<SKSelectionState, Never> {
        Publishers
            .CombineLatest3(selectedPublisher, canSelectPublisher, enabledPublisher)
            .compactMap({ [weak self] _ in
                guard let self = self else { return nil }
                return self
            })
            .eraseToAnyPublisher()
    }
    
    // 返回一个延迟发布的 AnyPublisher，用于订阅 isEnabled 属性的变化
    public lazy var enabledPublisher = deferred(value: isEnabled, bind: \.enabledSubject).removeDuplicates().eraseToAnyPublisher()
    
    // 返回一个延迟发布的 AnyPublisher，用于订阅 canSelect 属性的变化
    public lazy var canSelectPublisher = deferred(value: canSelect, bind: \.canSelectSubject).removeDuplicates().eraseToAnyPublisher()
    
    // 返回一个延迟发布的 AnyPublisher，用于订阅 isSelected 属性的变化
    public lazy var selectedPublisher  = deferred(value: isSelected, bind: \.selectedSubject).removeDuplicates().eraseToAnyPublisher()
    
    // 保存 isSelected 属性的值
    private var selectedSubject:  CurrentValueSubject<Bool, Never>?
    
    // 保存 canSelect 属性的值
    private var canSelectSubject: CurrentValueSubject<Bool, Never>?
    
    // 保存 isEnabled 属性的值
    private var enabledSubject: CurrentValueSubject<Bool, Never>?
    
    // 判断两个 SKSelectionState 是否相等
    public static func == (lhs: SKSelectionState, rhs: SKSelectionState) -> Bool {
        return lhs.id == rhs.id
    }
    
    // 是否被选中
    public var isSelected: Bool {
        didSet {
            selectedSubject?.send(isSelected)
        }
    }
    
    // 是否能够被选择
    public var canSelect: Bool {
        didSet {
            canSelectSubject?.send(canSelect)
        }
    }
    
    // 是否允许选中或取消选中操作
    public var isEnabled: Bool {
        didSet {
            enabledSubject?.send(isEnabled)
        }
    }
    
    // 初始化函数
    public init(isSelected: Bool = false,
                canSelect: Bool = true,
                isEnabled: Bool = true) {
        self.isSelected = isSelected
        self.canSelect = canSelect
        self.isEnabled = isEnabled
    }
    
    // 返回一个延迟发布的 AnyPublisher
    private func deferred<Output, Failure: Error>(value: Output, bind: WritableKeyPath<SKSelectionState, CurrentValueSubject<Output, Failure>?>) -> AnyPublisher<Output, Failure> {
        return Deferred { [weak self] in
            guard var self = self else {
                return PassthroughSubject<Output, Failure>().eraseToAnyPublisher()
            }
            if let subject = self[keyPath: bind] {
                return subject.eraseToAnyPublisher()
            }
            let subject = CurrentValueSubject<Output, Failure>(value)
            self[keyPath: bind] = subject
            return subject.eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
