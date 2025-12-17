# Vector Sketch App for iPad

A vector-based drawing application for iPad Air with Apple Pencil support. The app captures drawings as pure vector data (no bitmaps/rasterization) and can export to SVG format for LLM analysis.

## Features

- ✅ **iPad Air Compatible**: Optimized for iPad Air and other iPad models
- ✅ **Apple Pencil Support**: Full support for Apple Pencil input with pressure sensitivity
- ✅ **Vector-Based Drawing**: All drawings are stored as vector paths (Bezier curves)
- ✅ **No Rasterization**: Pure vector representation, no bitmap conversion
- ✅ **SVG Export**: Exports drawings to industry-standard SVG format
- ✅ **LLM Ready**: Designed to send vector drawings to LLMs for analysis
- ✅ **Isomorphic to SVG**: Drawing representation is limited by and compatible with SVG spec

## Architecture

The app uses a clean SwiftUI architecture with the following components:

### Core Components

1. **VectorSketchApp.swift** - Main app entry point
2. **ContentView.swift** - Main UI with canvas and controls
3. **DrawingModel.swift** - Data model managing vector strokes
4. **DrawingCanvasView.swift** - Custom UIView for Apple Pencil input

### Data Model

- **VectorStroke**: Represents a single drawing stroke as a collection of CGPoints
- **CodableColor**: Color representation that can be serialized
- **DrawingModel**: Observable model managing all strokes and export functionality

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **UIKit Integration**: Custom UIView for precise touch/pencil handling
- **Core Graphics**: Vector path rendering
- **SVG Export**: Native SVG generation from vector paths

## Building and Running

### Requirements

- Xcode 15.0 or later
- iOS 16.0 or later
- iPad device or simulator

### Build Instructions

1. Open the project in Xcode:
   ```bash
   open VectorSketchApp.xcodeproj
   ```

2. Select an iPad simulator or connected iPad device as the target

3. Build and run the project (⌘R)

### Testing on iPad

For the best experience, deploy to a physical iPad with Apple Pencil support:
- iPad Air (3rd generation or later)
- iPad Pro (any generation)
- iPad mini (6th generation or later)

## Usage

1. **Draw**: Use Apple Pencil or finger to draw on the white canvas
2. **Clear**: Tap the "Clear" button to erase all strokes
3. **Export SVG**: Tap "Export SVG" to view and copy the SVG representation
4. **Send to LLM**: Tap "Send to LLM" to prepare drawing for LLM analysis (placeholder)

## SVG Format

The app exports drawings as valid SVG documents with the following characteristics:

- All strokes are `<path>` elements
- Stroke width and color are preserved
- No raster images or bitmap data
- Can be opened in any SVG-compatible viewer or editor
- Suitable for LLM vision models that accept SVG input

Example SVG output:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="768">
  <rect width="100%" height="100%" fill="white"/>
  <path d="M 100,100 L 150,150 L 200,100" stroke="#000000" 
        stroke-width="2.0" fill="none" 
        stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

## LLM Integration

The app is designed to send drawings to Large Language Models for analysis. To integrate with an LLM API:

1. Implement the `sendToLLM()` function in `ContentView.swift`
2. Use the `drawingModel.exportToSVG()` method to get the SVG string
3. Send the SVG data to your preferred LLM API (OpenAI, Anthropic, etc.)
4. Display or process the LLM's analysis response

Example integration points:
```swift
// Get SVG data
let svgData = drawingModel.exportToSVG()

// Get JSON representation of vector data
let jsonData = drawingModel.exportToJSON()
```

## Technical Details

### Vector Storage

- Drawings are stored as arrays of `VectorStroke` objects
- Each stroke contains an array of `CGPoint` coordinates
- No pixel buffers or raster images are used
- Memory efficient for complex drawings

### Apple Pencil Features

- Pressure sensitivity for variable stroke width
- Palm rejection through touch type detection
- Precise point sampling for smooth curves
- Support for tilt and azimuth (can be extended)

### Performance

- Real-time rendering using Core Graphics
- Efficient redraw on touch events
- Minimal memory footprint
- Smooth 120Hz drawing on ProMotion displays

## Future Enhancements

Potential improvements for future versions:

- [ ] Color picker for different stroke colors
- [ ] Eraser tool
- [ ] Undo/Redo functionality
- [ ] Multiple layers
- [ ] Shape recognition
- [ ] Export to other vector formats (PDF, EPS)
- [ ] Cloud sync for drawings
- [ ] Direct LLM API integration
- [ ] Tilt and azimuth support for advanced pencil features
- [ ] Gesture recognition for quick tools

## License

This project is open source. See LICENSE file for details.
