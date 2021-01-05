//
//  DrawnPath.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
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
        saveBezierPath()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brush = try values.decode(Brush.self, forKey: .brush)
        scale = try values.decode(CGFloat.self, forKey: .scale)
        uuid = try values.decode(String.self, forKey: .uuid)
        bezierPath = DrawnPath.loadBezierPath(uuid: uuid)
    }
    
    private func saveBezierPath() {
        let path = CacheModule.editor(.bezierPath).path
        let file = "\(path)\(uuid)"
        FileHelper.createDirectory(at: path)
        NSKeyedArchiver.archiveRootObject(bezierPath, toFile: file)
    }
    
    static private func loadBezierPath(uuid: String) -> UIBezierPath {
        let path = CacheModule.editor(.bezierPath).path
        let file = "\(path)\(uuid)"
        return (NSKeyedUnarchiver.unarchiveObject(withFile: file) as? UIBezierPath) ?? UIBezierPath()
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
