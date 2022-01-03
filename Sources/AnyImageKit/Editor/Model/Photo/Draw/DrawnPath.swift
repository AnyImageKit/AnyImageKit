//
//  DrawnPath.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// 画笔路径
/// 由于 UIBezierPath 不能遵守 Codable，所以通过 NSKeyedArchiver 存储。
struct DrawnPath: Codable {
    
    let brush: Brush
    let scale: CGFloat
    let bezierPath: UIBezierPath
    let uuid: String
    
    enum CodingKeys: String, CodingKey {
        case brush
        case scale
        case uuid
    }
    
    init(brush: Brush, scale: CGFloat, path: UIBezierPath) {
        self.brush = brush
        self.scale = scale
        self.bezierPath = path
        self.uuid = UUID().uuidString
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brush, forKey: .brush)
        try container.encode(scale, forKey: .scale)
        try container.encode(uuid, forKey: .uuid)
        try saveBezierPath()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brush = try values.decode(Brush.self, forKey: .brush)
        scale = try values.decode(CGFloat.self, forKey: .scale)
        uuid = try values.decode(String.self, forKey: .uuid)
        bezierPath = try DrawnPath.loadBezierPath(uuid: uuid)
    }
    
    private func saveBezierPath() throws {
        let path = CacheModule.editor(.bezierPath).path
        let file = "\(path)\(uuid)"
        FileHelper.createDirectory(at: path)
        if #available(iOS 11.0, macCatalyst 13.0, *) {
            let data = try NSKeyedArchiver.archivedData(withRootObject: bezierPath, requiringSecureCoding: true)
            let url = URL(fileURLWithPath: file)
            try data.write(to: url)
        } else {
            NSKeyedArchiver.archiveRootObject(bezierPath, toFile: file)
        }
    }
    
    static private func loadBezierPath(uuid: String) throws -> UIBezierPath {
        let path = CacheModule.editor(.bezierPath).path
        let file = "\(path)\(uuid)"
        if #available(iOS 11.0, macCatalyst 13.0, *) {
            let url = URL(fileURLWithPath: file)
            let data = try Data(contentsOf: url)
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIBezierPath.self, from: data) ?? UIBezierPath()
        } else {
            return (NSKeyedUnarchiver.unarchiveObject(withFile: file) as? UIBezierPath) ?? UIBezierPath()
        }
    }
}

// MARK: - GraphicsDrawing
extension DrawnPath: GraphicsDrawing {
    
    func draw(in context: CGContext, size: CGSize) {
        draw(in: context, size: size, scale: 1.0)
    }
    
    func draw(in context: CGContext, size: CGSize, scale: CGFloat) {
        UIGraphicsPushContext(context)
        context.saveGState()
        draw(scale: scale)
        context.restoreGState()
        UIGraphicsPopContext()
    }
    
    private func draw(scale: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.scaleBy(x: self.scale / scale, y: self.scale / scale)
        brush.color.setStroke()
        let bezierPath = brushedPath()
        bezierPath.stroke()
        context.restoreGState()
    }
    
    private func brushedPath() -> UIBezierPath {
        let _bezierPath = bezierPath.copy() as! UIBezierPath
        _bezierPath.lineJoinStyle = .round
        _bezierPath.lineCapStyle = .round
        _bezierPath.lineWidth = brush.lineWidth
        return _bezierPath
    }
}

extension DrawnPath: Equatable {
    
    static func == (lhs: DrawnPath, rhs: DrawnPath) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
