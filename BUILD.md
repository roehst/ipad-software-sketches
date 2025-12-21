# Build Instructions for Vector Sketch App

## Prerequisites

This is an iOS application that requires macOS and Xcode to build.

### Required Software

- **macOS**: Monterey (12.0) or later
- **Xcode**: 15.0 or later
- **iOS SDK**: 16.0 or later

### Optional

- **Physical iPad**: For best Apple Pencil testing experience
- **Apple Developer Account**: For device deployment (free or paid)

## Building the Project

### Using Xcode GUI

1. **Open the project**:
   ```bash
   open VectorSketchApp.xcodeproj
   ```

2. **Select a target**:
   - Choose "VectorSketchApp" scheme from the scheme selector
   - Select an iPad simulator or connected device as the destination

3. **Build the project**:
   - Press `⌘B` to build
   - Or select "Product" → "Build" from the menu

4. **Run the app**:
   - Press `⌘R` to build and run
   - Or select "Product" → "Run" from the menu

### Using Command Line

1. **List available simulators**:
   ```bash
   xcrun simctl list devices available
   ```

2. **Build for simulator**:
   ```bash
   xcodebuild \
     -project VectorSketchApp.xcodeproj \
     -scheme VectorSketchApp \
     -destination 'platform=iOS Simulator,name=iPad Air (5th generation)' \
     build
   ```

3. **Build and run**:
   ```bash
   xcodebuild \
     -project VectorSketchApp.xcodeproj \
     -scheme VectorSketchApp \
     -destination 'platform=iOS Simulator,name=iPad Air (5th generation)' \
     build \
     CODE_SIGN_IDENTITY="" \
     CODE_SIGNING_REQUIRED=NO
   ```

4. **Install on device** (requires Apple Developer Account):
   ```bash
   xcodebuild \
     -project VectorSketchApp.xcodeproj \
     -scheme VectorSketchApp \
     -destination 'platform=iOS,name=Your iPad Name' \
     -configuration Release \
     build \
     archive \
     -archivePath ./build/VectorSketchApp.xcarchive
   ```

## Troubleshooting

### Common Issues

#### Code Signing Error

If you encounter code signing errors:

1. Open the project in Xcode
2. Select the "VectorSketchApp" target
3. Go to "Signing & Capabilities" tab
4. Select your development team or use "Sign to Run Locally"

#### Missing Simulator

If the iPad Air simulator is not available:

1. Open Xcode
2. Go to "Xcode" → "Preferences" → "Components"
3. Download iOS simulators for your target version

#### Build Failed

If the build fails:

1. Clean the build folder: `⌘⇧K` or "Product" → "Clean Build Folder"
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Restart Xcode

### Deployment Issues

#### Can't Install on Device

Ensure:
- Device is unlocked
- Device is trusted (check "Trust This Computer" on device)
- Correct deployment target is selected in project settings
- Valid provisioning profile is configured

## Testing

### On Simulator

The app works in the iOS Simulator, but Apple Pencil features are limited:
- Simulated pencil input via trackpad/mouse
- No pressure sensitivity
- No tilt/azimuth data

### On Physical Device

For full Apple Pencil testing:
1. Deploy to iPad with Apple Pencil support
2. Pair your Apple Pencil with the iPad
3. Test pressure sensitivity by varying drawing force
4. Test palm rejection by resting hand on screen while drawing

## Development

### Swift Version

This project uses Swift 5.0+ with SwiftUI.

### Minimum Deployment Target

- iOS 16.0
- iPadOS 16.0

### Supported Devices

- iPad Air (3rd generation and later)
- iPad Pro (all models)
- iPad (9th generation and later)
- iPad mini (6th generation and later)

## CI/CD

### GitHub Actions Setup

✅ **CI/CD is now configured!** The project includes a GitHub Actions workflow that:
- Automatically builds the iOS app
- Runs it in an iPad Air simulator
- Captures a screenshot of the running app
- Uploads the screenshot as an artifact

**Workflow File**: `.github/workflows/ios-build.yml`

**Status Badge**: 
[![iOS Build and Screenshot](https://github.com/roehst/ipad-software-sketches/actions/workflows/ios-build.yml/badge.svg)](https://github.com/roehst/ipad-software-sketches/actions/workflows/ios-build.yml)

For detailed information about the CI/CD setup, see [CI_CD.md](CI_CD.md).

### Viewing Screenshots

After the workflow runs successfully:
1. Go to the GitHub Actions tab
2. Click on a completed workflow run
3. Download the `app-screenshot` artifact
4. Extract and view the screenshot

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [PencilKit Documentation](https://developer.apple.com/documentation/pencilkit)
- [Core Graphics Documentation](https://developer.apple.com/documentation/coregraphics)
