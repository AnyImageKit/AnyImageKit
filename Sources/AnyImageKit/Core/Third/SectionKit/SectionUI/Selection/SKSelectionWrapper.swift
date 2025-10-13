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

import Foundation

@frozen
@propertyWrapper
@dynamicMemberLookup
public struct SKSelectionWrapper<WrappedValue>: SKSelectionProtocol, RawRepresentable, Identifiable, Equatable, Hashable {
    
    public var id: String
    public var selection: SKSelectionState
    public var wrappedValue: WrappedValue
    public var rawValue: WrappedValue { wrappedValue }
    
    public init(rawValue: WrappedValue) {
        self.init(rawValue)
    }
    
    public init(_ value: WrappedValue,
                _ selection: SKSelectionState = .init(),
                id: String = UUID().uuidString) {
        self.wrappedValue = value
        self.selection = selection
        self.id = id
    }

    public init(_ value: WrappedValue,
                _ selection: SKSelectionState = .init()) where WrappedValue: Identifiable, WrappedValue.ID == UUID {
        self.init(value, selection, id: value.id.uuidString)
    }
    
    public init(_ selection: SKSelectionState = .init()) where WrappedValue == Void {
        self.init((), selection)
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<WrappedValue, T>) -> T {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<WrappedValue, T>) -> T {
        wrappedValue[keyPath: keyPath]
    }
    
    public static func == (lhs: SKSelectionWrapper<WrappedValue>, rhs: SKSelectionWrapper<WrappedValue>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
