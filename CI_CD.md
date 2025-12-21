# CI/CD Documentation

## Overview

This project uses GitHub Actions for continuous integration and deployment. The CI/CD pipeline automatically builds the iOS app, runs it in a simulator, and captures screenshots on every push and pull request.

## GitHub Actions Workflow

### Workflow File

- **Location**: `.github/workflows/ios-build.yml`
- **Name**: iOS Build and Screenshot
- **Runner**: macOS 14 (required for iOS builds)

### Triggers

The workflow runs on:
- Push to `main` or `master` branches
- Pull requests to `main` or `master` branches
- Manual trigger via GitHub Actions UI (`workflow_dispatch`)

### Workflow Steps

1. **Checkout Code**: Clone the repository
2. **Select Xcode Version**: Use Xcode 15.2 for building
3. **Show Xcode Version**: Display Xcode version for debugging
4. **List Available Simulators**: Show all available iOS simulators
5. **Build for Simulator**: Build the app for iOS Simulator with code signing disabled
6. **Boot Simulator**: Start the iPad Air (5th generation) simulator
7. **Install App**: Install the built app on the simulator
8. **Launch App and Capture Screenshot**: Launch the app and take a screenshot
9. **Upload Screenshot**: Save screenshot as a workflow artifact
10. **Upload Build Logs**: Save build logs if the workflow fails
11. **Clean Up**: Shutdown the simulator

### Build Configuration

- **Platform**: iOS Simulator
- **Device**: iPad Air (5th generation)
- **iOS Version**: 17.2
- **Configuration**: Debug
- **Code Signing**: Disabled (not required for simulator builds)

### Artifacts

The workflow produces the following artifacts:

#### App Screenshot
- **Name**: `app-screenshot`
- **Path**: `screenshots/app-screenshot.png`
- **Retention**: 30 days
- **Description**: Screenshot of the app running in the simulator
- **Access**: Download from the workflow run's "Artifacts" section

#### Build Logs (on failure)
- **Name**: `build-logs`
- **Paths**: 
  - `./DerivedData/Logs`
  - `~/Library/Logs/DiagnosticReports`
- **Retention**: 7 days
- **Description**: Build logs and diagnostic reports for debugging failures

## Viewing CI/CD Status

### Build Status Badge

The README includes a build status badge that shows the current status of the CI/CD pipeline:

[![iOS Build and Screenshot](https://github.com/roehst/ipad-software-sketches/actions/workflows/ios-build.yml/badge.svg)](https://github.com/roehst/ipad-software-sketches/actions/workflows/ios-build.yml)

### GitHub Actions Tab

1. Go to the repository on GitHub
2. Click on the "Actions" tab
3. View all workflow runs and their status

### Viewing Screenshots

To view screenshots captured by the CI/CD pipeline:

1. Navigate to the Actions tab on GitHub
2. Select a workflow run
3. Scroll down to the "Artifacts" section
4. Download the `app-screenshot` artifact
5. Extract and view the PNG image

## Local Testing

Before pushing changes, you can test the build locally:

### Prerequisites

- macOS with Xcode 15.0 or later
- iOS Simulator installed

### Build Commands

```bash
# List available simulators
xcrun simctl list devices available

# Build the app
xcodebuild \
  -project VectorSketchApp.xcodeproj \
  -scheme VectorSketchApp \
  -destination 'platform=iOS Simulator,name=iPad Air (5th generation),OS=17.2' \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Boot simulator
DEVICE_ID=$(xcrun simctl list devices available | grep "iPad Air (5th generation)" | head -1 | grep -o "[A-F0-9\-]\{36\}")
xcrun simctl boot "$DEVICE_ID"

# Install and launch app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "VectorSketchApp.app" -type d | head -1)
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch "$DEVICE_ID" com.vectorsketch.app

# Capture screenshot
xcrun simctl io "$DEVICE_ID" screenshot screenshot.png

# Shutdown simulator
xcrun simctl shutdown "$DEVICE_ID"
```

## Troubleshooting

### Build Failures

If the CI/CD pipeline fails:

1. **Check Build Logs**: Download the `build-logs` artifact from the failed workflow run
2. **Review Error Messages**: Look for compilation errors or missing dependencies
3. **Verify Xcode Version**: Ensure the Xcode version in the workflow matches the project requirements
4. **Test Locally**: Try building the project on a local macOS machine

### Simulator Issues

If the simulator fails to boot or the app doesn't launch:

1. **Check Simulator Availability**: Ensure the specified simulator (iPad Air 5th gen, iOS 17.2) is available
2. **Adjust Device/OS**: Update the workflow to use a different device or iOS version if needed
3. **Increase Wait Times**: The workflow waits 10 seconds for the simulator to boot and 5 seconds for the app to launch. Increase these if needed.

### Screenshot Issues

If screenshots are not captured:

1. **Check App Launch**: Ensure the app launched successfully before the screenshot step
2. **Verify Bundle ID**: Confirm the bundle identifier `com.vectorsketch.app` matches the project
3. **Review Simulator Logs**: Check simulator logs for any errors

## Maintenance

### Updating Xcode Version

To use a different Xcode version:

1. Edit `.github/workflows/ios-build.yml`
2. Update the Xcode path in the "Select Xcode version" step
3. Example: Change `/Applications/Xcode_15.2.app` to `/Applications/Xcode_16.0.app`

### Changing Target Device

To use a different simulator:

1. Edit `.github/workflows/ios-build.yml`
2. Update the device name in the build destination
3. Update the device name in the "Boot simulator" step
4. Example: Change `iPad Air (5th generation)` to `iPad Pro (12.9-inch) (6th generation)`

### Adjusting iOS Version

To target a different iOS version:

1. Edit `.github/workflows/ios-build.yml`
2. Update the OS version in the build destination
3. Example: Change `OS=17.2` to `OS=18.0`

## GitHub Runners

### Runner Type

The workflow uses `macos-14` runners, which are GitHub-hosted macOS runners with:
- macOS 14 (Sonoma)
- Xcode 15.2 and other versions
- iOS simulators pre-installed
- 14 GB RAM
- 3-core CPU

### Runner Costs

- **Public Repositories**: Free unlimited minutes
- **Private Repositories**: Included minutes vary by plan, then billed per minute

For more information, see [GitHub Actions pricing](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions).

## Best Practices

1. **Keep Build Times Short**: The workflow currently takes 5-10 minutes. Optimize if it gets longer.
2. **Use Caching**: Consider adding caching for DerivedData to speed up builds (not currently implemented).
3. **Monitor Artifact Storage**: Screenshots are kept for 30 days. Adjust retention if needed.
4. **Test Before Merge**: Always review the CI/CD results before merging pull requests.
5. **Keep Screenshots Updated**: Review screenshots regularly to ensure they reflect the current UI.

## Future Enhancements

Potential improvements to the CI/CD pipeline:

- [ ] Add unit tests and run them in the CI pipeline
- [ ] Add UI tests using XCTest
- [ ] Cache DerivedData to speed up builds
- [ ] Test on multiple iOS versions
- [ ] Test on multiple device types (iPad Pro, iPad mini)
- [ ] Generate and upload IPA files for distribution
- [ ] Add code coverage reporting
- [ ] Add SwiftLint for code style checking
- [ ] Automated deployment to TestFlight
- [ ] Performance testing and metrics
