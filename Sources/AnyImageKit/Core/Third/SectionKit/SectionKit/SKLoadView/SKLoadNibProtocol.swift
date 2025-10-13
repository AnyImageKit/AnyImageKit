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

#if canImport(UIKit)
import UIKit

/// 从 Xib 加载当前视图
public protocol SKLoadNibProtocol: SKLoadViewProtocol {}

public extension SKLoadNibProtocol {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib? {
        return UINib(nibName: String(describing: Self.self), bundle: bundle(of: Self.self))
    }
    
    static var loadFromNib: Self {
        return nib!.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
    static func bundle(of anyClass: AnyClass) -> Bundle {
#if SWIFT_PACKAGE
        guard let moduleName = anyClass.description().components(separatedBy: ".").first else {
            return Bundle(for: anyClass)
        }
        let bundleName = "\(moduleName)_\(moduleName)"
        
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: anyClass).resourceURL,
            Bundle.main.bundleURL,
        ]
        
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: anyClass)
#else
        return Bundle(for: anyClass)
#endif
    }
    
}
#endif
