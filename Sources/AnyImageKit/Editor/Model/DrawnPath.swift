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
struct DrawnPath: GraphicsDrawing, Codable {
    
    let brush: Brush
    let bezierPath: UIBezierPath
    private let uuid: String
    
    enum CodingKeys: String, CodingKey {
        case brush
        case uuid
    }
    
    init(brush: Brush, path: UIBezierPath) {
        self.brush = brush
        self.bezierPath = path
        self.uuid = UUID().uuidString
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brush, forKey: .brush)
        try container.encode(uuid, forKey: .uuid)
        saveBezierPath()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brush = try values.decode(Brush.self, forKey: .brush)
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

extension DrawnPath {
    
    func draw(in context: CGContext, canvasSize: CGSize) {
        UIGraphicsPushContext(context)
        context.saveGState()
        defer {
            context.restoreGState()
            UIGraphicsPopContext()
        }
        draw()
    }
    
    private func draw() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        defer {
            context.restoreGState()
        }
        
        brush.color.setStroke()
        let bezierPath = brushedPath()
        bezierPath.stroke()
    }
    
    private func brushedPath() -> UIBezierPath {
        let _bezierPath = bezierPath.copy() as! UIBezierPath
        _bezierPath.lineJoinStyle = .round
        _bezierPath.lineCapStyle = .round
        _bezierPath.lineWidth = brush.lineWidth
        return _bezierPath
    }
}
