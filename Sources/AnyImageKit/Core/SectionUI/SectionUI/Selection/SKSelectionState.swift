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

public class SKSelectionState: Equatable {
    
    public var selectedPublisher:  AnyPublisher<Bool, Never> { selectedSubject.removeDuplicates().eraseToAnyPublisher() }
    public var canSelectPublisher: AnyPublisher<Bool, Never> { canSelectSubject.removeDuplicates().eraseToAnyPublisher() }
    public var isEnabledPublisher: AnyPublisher<Bool, Never> { isEnabledSubject.removeDuplicates().eraseToAnyPublisher() }
    public var changedPublisher:   AnyPublisher<SKSelectionState, Never> {
        Publishers
            .CombineLatest3(selectedPublisher, canSelectPublisher, isEnabledPublisher)
            .compactMap({ [weak self] _ in
                guard let self = self else { return nil }
                return self
            })
            .eraseToAnyPublisher()
    }
    
    private let selectedSubject:  CurrentValueSubject<Bool, Never>
    private let canSelectSubject: CurrentValueSubject<Bool, Never>
    private let isEnabledSubject: CurrentValueSubject<Bool, Never>
        
    public static func == (lhs: SKSelectionState, rhs: SKSelectionState) -> Bool {
        return lhs.isSelected == rhs.isSelected
        && lhs.canSelect == rhs.canSelect
        && lhs.isEnabled == rhs.isEnabled
    }
    
    public var isSelected: Bool {
        set {
            if isEnabled {
                selectedSubject.send(newValue)
            }
        }
        get { selectedSubject.value }
    }
    
    public var canSelect: Bool {
        set { canSelectSubject.send(newValue) }
        get { canSelectSubject.value }
    }
    
    /// 是否允许选中或取消选中操作
    public var isEnabled: Bool {
        set { isEnabledSubject.send(newValue) }
        get { isEnabledSubject.value }
    }
    
    public init(isSelected: Bool = false,
                canSelect: Bool = true,
                isEnabled: Bool = true) {
        isEnabledSubject = CurrentValueSubject<Bool, Never>(isEnabled)
        selectedSubject  = CurrentValueSubject<Bool, Never>(isSelected)
        canSelectSubject = CurrentValueSubject<Bool, Never>(canSelect)
    }
}
