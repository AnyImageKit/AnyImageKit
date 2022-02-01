//
//  DrawnPath.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct DrawnPath: Codable {
    
    let brush: Brush
    let points: [CGPoint]
    let uuid: String
    
    enum CodingKeys: String, CodingKey {
        case brush
        case points
        case uuid
    }
    
    init(brush: Brush, scale: CGFloat, points: [CGPoint]) {
        self.uuid = UUID().uuidString
        self.brush = Brush(color: brush.color, lineWidth: brush.lineWidth * scale)
        self.points = points.map {
             CGPoint(x: $0.x * scale, y: $0.y * scale)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brush, forKey: .brush)
        try container.encode(points, forKey: .points)
        try container.encode(uuid, forKey: .uuid)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brush = try values.decode(Brush.self, forKey: .brush)
        points = try values.decode([CGPoint].self, forKey: .points)
        uuid = try values.decode(String.self, forKey: .uuid)
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
        brush.color.setStroke()
        let bezierPath = brushedPath()
        bezierPath.stroke()
        context.restoreGState()
    }
    
    func brushedPath(scale: CGFloat = 1.0) -> DryDrawingBezierPath {
        let bezierPath = DryDrawingBezierPath()
        bezierPath.lineJoinStyle = .round
        bezierPath.lineCapStyle = .round
        bezierPath.lineWidth = brush.lineWidth * scale
        bezierPath.points = points
        for (index, point) in points.enumerated() {
            let p = CGPoint(x: point.x * scale, y: point.y * scale)
            if index == 0 {
                bezierPath.move(to: p)
            } else {
                bezierPath.addLine(to: p)
            }
        }
        return bezierPath
    }
}

// MARK: - Equatable
extension DrawnPath: Equatable {
    
    static func == (lhs: DrawnPath, rhs: DrawnPath) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
