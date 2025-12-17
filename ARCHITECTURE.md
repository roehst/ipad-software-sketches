# Architecture Documentation

## Overview

Vector Sketch App is built with a clean, maintainable architecture that separates concerns between UI, data management, and vector graphics handling.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    VectorSketchApp                       │
│                    (SwiftUI App)                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    ContentView                           │
│            (Main UI & Control Panel)                    │
│  - Clear Button                                         │
│  - Export SVG Button                                    │
│  - Send to LLM Button                                   │
└─────────────┬───────────────────────┬───────────────────┘
              │                       │
              ▼                       ▼
┌─────────────────────────┐  ┌──────────────────────────┐
│  DrawingCanvasView      │  │   DrawingModel           │
│  (UIViewRepresentable)  │◄─┤   (ObservableObject)     │
│                         │  │                          │
│  ┌───────────────────┐  │  │  - strokes: [VectorStroke]│
│  │DrawingCanvasUIView│  │  │  - currentStroke          │
│  │   (UIView)        │  │  │  - exportToSVG()         │
│  │                   │  │  │  - exportToJSON()        │
│  │ - Touch Handling  │  │  └──────────────────────────┘
│  │ - Apple Pencil    │  │              │
│  │ - Core Graphics   │  │              │
│  └───────────────────┘  │              ▼
└─────────────────────────┘  ┌──────────────────────────┐
                              │   VectorStroke           │
                              │   (Struct)               │
                              │                          │
                              │  - id: UUID              │
                              │  - points: [CGPoint]     │
                              │  - color: CodableColor   │
                              │  - width: CGFloat        │
                              │  - toSVGPath()           │
                              └──────────────────────────┘
```

## Component Details

### 1. VectorSketchApp

**Type**: SwiftUI App (entry point)

**Responsibilities**:
- App lifecycle management
- Root scene configuration
- Entry point for the application

**Key Code**:
```swift
@main
struct VectorSketchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. ContentView

**Type**: SwiftUI View

**Responsibilities**:
- Main user interface layout
- Control panel (buttons)
- SVG export sheet presentation
- Coordination between canvas and model

**State Management**:
- `@StateObject drawingModel`: The drawing data model
- `@State showingSVGExport`: Controls SVG export sheet
- `@State exportedSVG`: Stores exported SVG content

**User Actions**:
- Clear drawing
- Export to SVG
- Send to LLM (placeholder)

### 3. DrawingCanvasView

**Type**: UIViewRepresentable (SwiftUI wrapper for UIView)

**Responsibilities**:
- Bridge between SwiftUI and UIKit
- Creates and manages DrawingCanvasUIView
- Passes DrawingModel to UIView

**Why UIKit?**:
SwiftUI doesn't provide low-level touch handling needed for precise Apple Pencil input. UIKit's touch APIs give us:
- Touch pressure/force
- Touch type (finger vs. pencil)
- Precise point sampling
- Touch prediction

### 4. DrawingCanvasUIView

**Type**: UIView (UIKit custom view)

**Responsibilities**:
- Handles all touch events
- Differentiates Apple Pencil from finger input
- Renders vector strokes using Core Graphics
- Real-time drawing feedback

**Touch Handling**:
```swift
- touchesBegan: Start new stroke
- touchesMoved: Add points to current stroke
- touchesEnded: Finalize stroke
- touchesCancelled: Handle interruptions
```

**Apple Pencil Features**:
- Pressure sensitivity (`touch.force`)
- Touch type detection (`touch.type == .pencil`)
- Variable stroke width based on pressure

**Rendering**:
- Uses Core Graphics (`UIGraphicsGetCurrentContext()`)
- Draws bezier paths from point arrays
- Efficient incremental updates

### 5. DrawingModel

**Type**: ObservableObject (data model)

**Responsibilities**:
- Store all completed strokes
- Manage current stroke being drawn
- Export to SVG format
- Export to JSON format
- Canvas size tracking

**Data Structures**:
```swift
@Published var strokes: [VectorStroke]
@Published var currentStroke: VectorStroke?
var canvasSize: CGSize
```

**Key Methods**:
- `startStroke()`: Begin new stroke
- `addPoint()`: Add point to current stroke
- `endStroke()`: Complete and save stroke
- `clear()`: Remove all strokes
- `exportToSVG()`: Generate SVG document
- `exportToJSON()`: Serialize to JSON

### 6. VectorStroke

**Type**: Struct (value type)

**Responsibilities**:
- Represent a single drawing stroke
- Store vector data (points, not pixels)
- Convert to SVG path element
- Serialization support

**Properties**:
```swift
let id: UUID              // Unique identifier
var points: [CGPoint]     // Vector path points
var color: CodableColor   // Stroke color
var width: CGFloat        // Stroke width
```

**SVG Conversion**:
Generates SVG `<path>` elements with proper attributes:
- `d`: Path data (M for move, L for line)
- `stroke`: Color in hex format
- `stroke-width`: Line width
- `fill`: None (outline only)
- `stroke-linecap`: Rounded ends
- `stroke-linejoin`: Rounded corners

### 7. CodableColor

**Type**: Struct (value type)

**Responsibilities**:
- Wrap SwiftUI Color for serialization
- Convert between Color and RGBA components
- Export to hex format for SVG

**Properties**:
```swift
var red: Double
var green: Double
var blue: Double
var alpha: Double
```

## Data Flow

### Drawing Flow

1. User touches screen with Apple Pencil
2. `DrawingCanvasUIView.touchesBegan()` receives touch
3. Create new `VectorStroke` in `DrawingModel`
4. `touchesMoved()` adds points to current stroke
5. `setNeedsDisplay()` triggers redraw
6. `draw()` renders all strokes with Core Graphics
7. `touchesEnded()` finalizes and saves stroke
8. Stroke added to `DrawingModel.strokes` array

### SVG Export Flow

1. User taps "Export SVG" button
2. `ContentView` calls `drawingModel.exportToSVG()`
3. `DrawingModel` generates SVG document string
4. For each stroke, call `stroke.toSVGPath()`
5. Combine all paths into complete SVG document
6. Display in `SVGExportView` sheet
7. User can copy to clipboard

### LLM Integration Flow (Placeholder)

1. User taps "Send to LLM" button
2. `ContentView.sendToLLM()` called
3. Export drawing to SVG: `drawingModel.exportToSVG()`
4. Send SVG to LLM API (to be implemented)
5. Receive and display analysis (to be implemented)

## Design Decisions

### Why Pure Vector Storage?

**Advantages**:
- Infinite resolution (scalable)
- Small file size
- Editable after creation
- Perfect for LLM analysis
- SVG compatible

**Trade-offs**:
- More complex rendering
- Cannot capture raster effects
- Limited to geometric shapes

### Why Not PencilKit?

PencilKit is Apple's drawing framework, but it:
- Uses raster-based rendering
- Stores bitmap data internally
- Harder to export to pure vector
- Less control over data format

Our custom solution:
- Pure vector from the start
- Direct SVG compatibility
- Full control over export format
- Optimized for LLM consumption

### Why SwiftUI + UIKit Hybrid?

**SwiftUI for**:
- Modern declarative UI
- Easy state management
- Built-in preview support
- Less boilerplate code

**UIKit for**:
- Low-level touch handling
- Apple Pencil pressure
- Custom drawing with Core Graphics
- Precise control over rendering

### Thread Safety

- Main thread: All UI and drawing operations
- Drawing updates: Synchronous on main thread
- No background threading needed (fast enough)

### Memory Management

- Automatic reference counting (ARC)
- Value types (structs) for stroke data
- Efficient point storage (array of CGPoint)
- Clear operation frees all stroke memory

## Extension Points

### Adding New Features

**Color Picker**:
- Add color property to ContentView
- Pass to DrawingModel.startStroke()
- Update UI with color selection buttons

**Eraser**:
- Add erase mode boolean
- On touch, remove intersecting strokes
- Use CGPath hit testing

**Undo/Redo**:
- Add stroke history stack
- Record each operation
- Implement reverse operations

**Shape Recognition**:
- Analyze point patterns in VectorStroke
- Detect lines, circles, rectangles
- Replace with perfect geometric shapes

**Multiple Layers**:
- Change strokes to nested structure
- Add layer management UI
- Export layers separately or combined

## Performance Considerations

### Rendering Performance

- Core Graphics is GPU-accelerated
- Only redraw on touch events
- Efficient path construction
- Minimal overdraw

### Memory Usage

- Each point is 16 bytes (CGFloat x 2)
- Typical stroke: 50-200 points
- 1000 strokes ≈ 1-3 MB
- Very efficient for iPad memory

### Export Performance

- SVG generation is string concatenation
- Linear time O(n) in number of strokes
- Fast enough for real-time export
- Could be optimized with StringBuilder

## Testing Strategy

### Unit Tests (Not Implemented)

Recommended tests:
- VectorStroke SVG generation
- Color hex conversion
- Point storage and retrieval
- Export format validation

### Integration Tests (Not Implemented)

Recommended tests:
- Complete drawing flow
- Export functionality
- Touch handling accuracy
- Memory leak detection

### Manual Testing

Required tests:
- Apple Pencil pressure response
- Palm rejection
- Drawing smoothness
- SVG output validity
- Copy/paste functionality

## Security Considerations

### Data Privacy

- All drawing data stays on device
- No automatic cloud sync
- User controls export
- No telemetry or analytics

### LLM Integration

When implementing:
- Use HTTPS for API calls
- Validate API responses
- Handle errors gracefully
- Allow user to review before sending
- Clear indication of data transmission

## Future Architecture Improvements

### Bezier Curve Optimization

Current: Store all raw points
Better: Convert to cubic Bezier curves
Benefits: Smaller size, smoother, more efficient

### Incremental Rendering

Current: Redraw everything on change
Better: Layer-based rendering with caching
Benefits: Better performance with many strokes

### Async Export

Current: Synchronous SVG generation
Better: Async generation with progress
Benefits: Non-blocking UI for large drawings

### Modular LLM Interface

Current: Placeholder implementation
Better: Protocol-based LLM service
Benefits: Support multiple LLM providers
