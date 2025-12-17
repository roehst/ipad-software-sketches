//
//  DrawingModel.swift
//  VectorSketchApp
//
//  Model to store and manage vector-based drawing strokes
//

import Foundation
import CoreGraphics
import SwiftUI

/// Extension to make CGPoint Codable for JSON serialization
extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}

/// Represents a single drawing stroke as a vector path
struct VectorStroke: Identifiable, Codable {
    let id: UUID
    var points: [CGPoint]
    var color: CodableColor
    var width: CGFloat
    
    init(id: UUID = UUID(), points: [CGPoint] = [], color: CodableColor = CodableColor(color: .black), width: CGFloat = 2.0) {
        self.id = id
        self.points = points
        self.color = color
        self.width = width
    }
    
    /// Convert stroke to SVG path element
    func toSVGPath() -> String {
        guard !points.isEmpty else { return "" }
        
        var pathData = "M \(points[0].x),\(points[0].y)"
        
        if points.count > 1 {
            // Use quadratic Bezier curves for smooth paths
            for i in 1..<points.count {
                pathData += " L \(points[i].x),\(points[i].y)"
            }
        }
        
        let colorHex = color.toHex()
        return "<path d=\"\(pathData)\" stroke=\"\(colorHex)\" stroke-width=\"\(width)\" fill=\"none\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    }
}

/// Color wrapper that conforms to Codable
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(color: Color) {
        // Convert SwiftUI Color to components
        // Default to black if conversion fails
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    func toHex() -> String {
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

/// Main drawing model that manages all strokes
class DrawingModel: ObservableObject {
    @Published var strokes: [VectorStroke] = []
    @Published var currentStroke: VectorStroke?
    
    var canvasSize: CGSize = .zero
    
    func startStroke(at point: CGPoint, color: Color = .black, width: CGFloat = 2.0) {
        currentStroke = VectorStroke(points: [point], color: CodableColor(color: color), width: width)
    }
    
    func addPoint(_ point: CGPoint) {
        guard currentStroke != nil else { return }
        currentStroke?.points.append(point)
    }
    
    func endStroke() {
        guard let stroke = currentStroke else { return }
        if !stroke.points.isEmpty {
            strokes.append(stroke)
        }
        currentStroke = nil
    }
    
    func clear() {
        strokes.removeAll()
        currentStroke = nil
    }
    
    /// Export all strokes as SVG format
    func exportToSVG() -> String {
        let width = canvasSize.width > 0 ? canvasSize.width : 1024
        let height = canvasSize.height > 0 ? canvasSize.height : 768
        
        var svg = """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg" width="\(width)" height="\(height)" viewBox="0 0 \(width) \(height)">
        <rect width="100%" height="100%" fill="white"/>
        
        """
        
        // Add all completed strokes
        for stroke in strokes {
            svg += "  \(stroke.toSVGPath())\n"
        }
        
        // Add current stroke if exists
        if let current = currentStroke {
            svg += "  \(current.toSVGPath())\n"
        }
        
        svg += "</svg>"
        
        return svg
    }
    
    /// Export drawing data as JSON for API transmission
    func exportToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(strokes)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding strokes to JSON: \(error)")
            return nil
        }
    }
}
