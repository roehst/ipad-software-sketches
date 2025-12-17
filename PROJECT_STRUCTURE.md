# Project Structure

```
ipad-software-sketches/
├── .gitignore                          # Xcode and build artifacts exclusions
├── README.md                           # Main project documentation
├── BUILD.md                            # Build and deployment instructions
├── ARCHITECTURE.md                     # Detailed architecture documentation
├── LLM_INTEGRATION.md                  # Guide for LLM API integration
│
├── VectorSketchApp.xcodeproj/          # Xcode project configuration
│   └── project.pbxproj                 # Project build settings and file references
│
└── VectorSketchApp/                    # Main application code
    ├── VectorSketchApp.swift           # App entry point (@main)
    ├── ContentView.swift               # Main UI with controls
    ├── DrawingCanvasView.swift         # Canvas with Apple Pencil support
    ├── DrawingModel.swift              # Vector stroke data model
    ├── Info.plist                      # App configuration and capabilities
    └── Assets.xcassets/                # App assets and resources
        ├── Contents.json
        ├── AppIcon.appiconset/         # App icon assets
        │   └── Contents.json
        └── AccentColor.colorset/       # Accent color definition
            └── Contents.json
```

## File Purposes

### Root Level

- **README.md**: Overview, features, usage instructions
- **BUILD.md**: How to build and run the app
- **ARCHITECTURE.md**: Technical architecture and design decisions
- **LLM_INTEGRATION.md**: How to integrate with LLM APIs
- **.gitignore**: Exclude Xcode build artifacts and user-specific files

### Xcode Project

- **project.pbxproj**: Xcode project file defining targets, build phases, and file references

### Application Code

- **VectorSketchApp.swift**: SwiftUI app entry point, defines app lifecycle
- **ContentView.swift**: Main view with drawing canvas and control buttons
- **DrawingCanvasView.swift**: UIKit-based canvas for Apple Pencil input
- **DrawingModel.swift**: Data model managing vector strokes and exports
- **Info.plist**: App metadata, device capabilities, orientations

### Assets

- **Assets.xcassets**: Asset catalog for app resources
- **AppIcon.appiconset**: App icon in various sizes
- **AccentColor.colorset**: App accent color definition

## Key Features by File

### VectorSketchApp.swift
- SwiftUI app initialization
- Window group configuration

### ContentView.swift
- Main UI layout
- Control buttons (Clear, Export SVG, Send to LLM)
- SVG export modal view
- State management

### DrawingCanvasView.swift
- UIViewRepresentable wrapper
- DrawingCanvasUIView (UIKit custom view)
- Touch event handling
- Apple Pencil pressure detection
- Core Graphics rendering

### DrawingModel.swift
- VectorStroke struct (points, color, width)
- CodableColor struct (serializable color)
- DrawingModel class (ObservableObject)
- SVG export (toSVGPath, exportToSVG)
- JSON export (exportToJSON)

## Data Flow

```
User Touch → DrawingCanvasUIView → DrawingModel → VectorStroke[]
                                                         ↓
                                              SVG/JSON Export
                                                         ↓
                                                    LLM API
```

## Build Artifacts (Not in Git)

These are generated during build and excluded by .gitignore:

```
Build/                      # Build output
DerivedData/               # Xcode build cache
xcuserdata/                # User-specific Xcode settings
*.xcworkspace/             # Workspace file (if using Swift Package Manager)
```

## Minimum Requirements

- **Xcode**: 15.0+
- **iOS**: 16.0+
- **Device**: iPad (any model)
- **Optional**: Apple Pencil for best experience

## Getting Started

1. Clone repository
2. Open `VectorSketchApp.xcodeproj` in Xcode
3. Select iPad simulator or device
4. Build and run (⌘R)

For detailed instructions, see BUILD.md
