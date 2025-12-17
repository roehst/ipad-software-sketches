//
//  DrawingCanvasView.swift
//  VectorSketchApp
//
//  Canvas view with Apple Pencil support for vector drawing
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @ObservedObject var drawingModel: DrawingModel
    
    func makeUIView(context: Context) -> DrawingCanvasUIView {
        let view = DrawingCanvasUIView()
        view.drawingModel = drawingModel
        return view
    }
    
    func updateUIView(_ uiView: DrawingCanvasUIView, context: Context) {
        // Update if needed
    }
}

/// Custom UIView that handles touch and Apple Pencil input
class DrawingCanvasUIView: UIView {
    weak var drawingModel: DrawingModel?
    private var currentTouchType: UITouch.TouchType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        isMultipleTouchEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawingModel?.canvasSize = bounds.size
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let model = drawingModel else { return }
        
        // Draw all completed strokes
        for stroke in model.strokes {
            drawStroke(stroke, in: context)
        }
        
        // Draw current stroke being drawn
        if let currentStroke = model.currentStroke {
            drawStroke(currentStroke, in: context)
        }
    }
    
    private func drawStroke(_ stroke: VectorStroke, in context: CGContext) {
        guard stroke.points.count > 0 else { return }
        
        context.setLineWidth(stroke.width)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        let uiColor = UIColor(stroke.color.color)
        context.setStrokeColor(uiColor.cgColor)
        
        context.beginPath()
        context.move(to: stroke.points[0])
        
        for i in 1..<stroke.points.count {
            context.addLine(to: stroke.points[i])
        }
        
        context.strokePath()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentTouchType = touch.type
        
        let location = touch.location(in: self)
        
        // Determine stroke width based on touch type and force
        var strokeWidth: CGFloat = 2.0
        
        if touch.type == .pencil {
            // Apple Pencil support - use force for variable width
            strokeWidth = touch.force > 0 ? max(1.0, touch.force * 3.0) : 2.0
        } else {
            // Finger touch
            strokeWidth = 4.0
        }
        
        drawingModel?.startStroke(at: location, color: .black, width: strokeWidth)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        drawingModel?.addPoint(location)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawingModel?.endStroke()
        currentTouchType = nil
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawingModel?.endStroke()
        currentTouchType = nil
        setNeedsDisplay()
    }
}
