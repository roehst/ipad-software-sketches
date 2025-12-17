# Quick Start Guide

Welcome to Vector Sketch App! This guide will get you up and running in minutes.

## What You Get

A fully functional iPad drawing app that:
- ✅ Works on iPad Air (and all iPads)
- ✅ Supports Apple Pencil with pressure sensitivity
- ✅ Stores drawings as pure vectors (no bitmaps)
- ✅ Exports to SVG format
- ✅ Ready for LLM integration

## Prerequisites

- Mac with macOS Monterey (12.0) or later
- Xcode 15.0 or later
- iPad or iPad Simulator

## 5-Minute Setup

### 1. Open the Project

```bash
cd /path/to/ipad-software-sketches
open VectorSketchApp.xcodeproj
```

### 2. Select a Target

In Xcode:
- Click on the scheme selector (top left)
- Choose an iPad simulator (e.g., "iPad Air (5th generation)")
- Or connect your physical iPad and select it

### 3. Build and Run

Press `⌘R` or click the Play button

That's it! The app should launch on your simulator or device.

## First Steps

### Try Drawing

1. Use your finger (on simulator) or Apple Pencil (on device) to draw
2. Notice how the pencil pressure affects stroke width
3. Draw some shapes, lines, or sketches

### Export to SVG

1. Tap the "Export SVG" button
2. View your drawing as SVG code
3. Tap "Copy" to copy the SVG to clipboard
4. Paste it into any text editor or SVG viewer

### Clear Canvas

Tap the "Clear" button to start fresh

### Send to LLM (Coming Soon)

The "Send to LLM" button is ready for you to integrate with your preferred LLM API.

## What's Next?

### Add LLM Integration

See `LLM_INTEGRATION.md` for detailed instructions on connecting to:
- OpenAI GPT-4 Vision
- Anthropic Claude
- Google Gemini
- Other LLM APIs

Example code is provided for each provider.

### Customize the App

#### Change Drawing Color

In `ContentView.swift`, modify:
```swift
drawingModel.startStroke(at: location, color: .blue, width: strokeWidth)
```

#### Add More Buttons

Add new buttons to the control panel in `ContentView.swift`:
```swift
Button(action: {
    // Your action
}) {
    Label("New Feature", systemImage: "star")
}
```

#### Adjust Stroke Width

In `DrawingCanvasView.swift`, modify pressure mapping:
```swift
strokeWidth = touch.force > 0 ? max(1.0, touch.force * 5.0) : 2.0
```

## Testing on Physical iPad

For the best experience:

1. **Connect your iPad** via USB
2. **Trust the computer** (dialog appears on iPad)
3. **Select your iPad** as the target in Xcode
4. **Run the app** (⌘R)
5. **Use Apple Pencil** for pressure-sensitive drawing

If you get a code signing error:
1. Select the "VectorSketchApp" target
2. Go to "Signing & Capabilities"
3. Select your Apple ID team or use "Sign to Run Locally"

## Project Structure

```
VectorSketchApp/
├── VectorSketchApp.swift       # App entry point
├── ContentView.swift           # Main UI
├── DrawingCanvasView.swift     # Canvas with Apple Pencil
├── DrawingModel.swift          # Vector data model
├── Info.plist                  # App configuration
└── Assets.xcassets/           # App resources
```

## Key Files to Know

| File | Purpose | When to Edit |
|------|---------|--------------|
| `ContentView.swift` | Main UI and controls | Add buttons, change layout |
| `DrawingCanvasView.swift` | Touch/pencil handling | Adjust drawing behavior |
| `DrawingModel.swift` | Data storage and export | Change data format, add features |
| `Info.plist` | App configuration | Add capabilities, change settings |

## Common Tasks

### Change App Name

1. Open `Info.plist`
2. Change `CFBundleDisplayName` value

### Add New Colors

In `ContentView.swift`:
```swift
@State private var selectedColor: Color = .black

// Add color picker
ColorPicker("Color", selection: $selectedColor)

// Use in drawing
drawingModel.startStroke(at: point, color: selectedColor, width: width)
```

### Export to File

```swift
let svg = drawingModel.exportToSVG()
let fileURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("drawing.svg")
try svg.write(to: fileURL, atomically: true, encoding: .utf8)
```

### Load Sample Drawing

```swift
// In DrawingModel
func loadSample() {
    let stroke = VectorStroke(
        points: [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 200),
            CGPoint(x: 300, y: 100)
        ],
        color: CodableColor(color: .blue),
        width: 3.0
    )
    strokes.append(stroke)
}
```

## Troubleshooting

### App Won't Build

**Problem**: Build errors in Xcode  
**Solution**: 
1. Clean build folder: `⌘⇧K`
2. Restart Xcode
3. Check Swift version is 5.0+

### Apple Pencil Not Working

**Problem**: Drawing works but no pressure sensitivity  
**Solution**: 
- Make sure you're on a physical iPad (not simulator)
- Check if Apple Pencil is paired
- Verify `touch.type == .pencil` in code

### SVG Export is Empty

**Problem**: Export shows empty SVG  
**Solution**: 
- Make sure you've drawn something first
- Check that strokes are being saved
- Verify canvas size is set

### Can't Deploy to iPad

**Problem**: "No provisioning profiles found"  
**Solution**:
1. Go to Signing & Capabilities
2. Select your team
3. Enable "Automatically manage signing"

## Getting Help

### Documentation

- `README.md` - Project overview and features
- `ARCHITECTURE.md` - Technical design and architecture
- `BUILD.md` - Detailed build instructions
- `LLM_INTEGRATION.md` - LLM API integration guide
- `PROJECT_STRUCTURE.md` - File organization

### Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [UIKit Touch Handling](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures)
- [SVG Specification](https://www.w3.org/TR/SVG2/)
- [Apple Pencil Interactions](https://developer.apple.com/design/human-interface-guidelines/apple-pencil)

## Next Steps

1. ✅ **You're Done!** The app is fully functional
2. 🎨 **Customize** - Add colors, tools, or features
3. 🤖 **Integrate LLM** - Connect to your favorite AI service
4. 📱 **Deploy** - Test on your iPad with Apple Pencil
5. 🚀 **Ship** - Submit to App Store (optional)

## Example Use Cases

### Software Specification Tool

Draw UI mockups → Export SVG → Send to LLM → Get implementation specs

### Diagram Analyzer

Draw flowcharts → Export SVG → Send to LLM → Get analysis

### Sketch to Code

Draw components → Export SVG → Send to LLM → Generate code

### Design Assistant

Draw layouts → Export SVG → Send to LLM → Get feedback

## Tips for Best Results

### Drawing Tips

- Use smooth, continuous strokes
- Vary pressure for emphasis
- Keep shapes simple for better LLM analysis
- Use clear, distinct elements

### LLM Integration Tips

- Include context in your prompts
- Ask specific questions about the drawing
- Iterate on the analysis
- Save good prompts for reuse

### Performance Tips

- Clear old drawings to free memory
- Export frequently to avoid data loss
- Use iPad Pro for best Apple Pencil experience
- Enable ProMotion for smoother drawing

## Feedback Welcome

This is an open-source project. Contributions, issues, and suggestions are welcome!

---

**Ready to start drawing? Open Xcode and hit ⌘R!**
