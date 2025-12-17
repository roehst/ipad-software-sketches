# LLM Integration Guide

This guide explains how to integrate the Vector Sketch App with Large Language Models (LLMs) for drawing analysis.

## Overview

The app exports drawings in two formats suitable for LLM analysis:

1. **SVG Format** - Industry-standard vector graphics
2. **JSON Format** - Structured vector data

Both formats are vector-based (no rasterization), preserving the drawing's geometric properties.

## Export Formats

### SVG Export

The SVG format is ideal for LLMs with vision capabilities:

```swift
let svgString = drawingModel.exportToSVG()
```

Example output:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="768" viewBox="0 0 1024 768">
<rect width="100%" height="100%" fill="white"/>
  <path d="M 100,100 L 150,120 L 200,100" stroke="#000000" stroke-width="2.0" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### JSON Export

For structured data analysis:

```swift
let jsonString = drawingModel.exportToJSON()
```

Example output:
```json
[
  {
    "id": "UUID-STRING",
    "points": [
      {"x": 100, "y": 100},
      {"x": 150, "y": 120},
      {"x": 200, "y": 100}
    ],
    "color": {
      "red": 0.0,
      "green": 0.0,
      "blue": 0.0,
      "alpha": 1.0
    },
    "width": 2.0
  }
]
```

## LLM Provider Integration

### OpenAI GPT-4 Vision

OpenAI's GPT-4V can analyze images, including SVG. To integrate:

1. **Add OpenAI SDK** (or use URLSession):
   ```swift
   // Add to your project
   import OpenAI
   ```

2. **Convert SVG to image** (for GPT-4V):
   ```swift
   func sendToOpenAI(svgData: String) async throws -> String {
       // Option 1: Send SVG as text in prompt
       let prompt = """
       Analyze this drawing in SVG format:
       \(svgData)
       
       Please describe what is drawn and provide insights.
       """
       
       // Option 2: Render SVG to PNG and send as image
       let pngData = renderSVGToPNG(svgData)
       
       // Make API call
       let response = try await openAI.chat.completions.create(
           model: "gpt-4-vision-preview",
           messages: [
               .system("You are an expert at analyzing technical drawings."),
               .user([
                   .text(prompt),
                   .image(pngData, mimeType: "image/png")
               ])
           ]
       )
       
       return response.choices[0].message.content
   }
   ```

### Anthropic Claude

Claude can analyze both images and structured data:

```swift
func sendToClaude(svgData: String) async throws -> String {
    let apiKey = "YOUR_API_KEY" // Store securely
    let url = URL(string: "https://api.anthropic.com/v1/messages")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
    
    let body: [String: Any] = [
        "model": "claude-3-opus-20240229",
        "max_tokens": 1024,
        "messages": [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": "Analyze this SVG drawing: \(svgData)"
                    ]
                ]
            ]
        ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(ClaudeResponse.self, from: data)
    
    return response.content[0].text
}

struct ClaudeResponse: Codable {
    let content: [Content]
    
    struct Content: Codable {
        let text: String
    }
}
```

### Google Gemini

Gemini supports multimodal input:

```swift
func sendToGemini(svgData: String) async throws -> String {
    let apiKey = "YOUR_API_KEY"
    let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-pro-vision:generateContent?key=\(apiKey)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "contents": [
            [
                "parts": [
                    ["text": "Analyze this SVG drawing and provide insights:"],
                    ["text": svgData]
                ]
            ]
        ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
    
    return response.candidates[0].content.parts[0].text
}
```

## Implementation Example

Add this to `ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var drawingModel = DrawingModel()
    @State private var llmResponse = ""
    @State private var isAnalyzing = false
    @State private var showingResponse = false
    
    // ... existing code ...
    
    private func sendToLLM() async {
        isAnalyzing = true
        
        do {
            let svg = drawingModel.exportToSVG()
            llmResponse = try await analyzeWithLLM(svgData: svg)
            showingResponse = true
        } catch {
            llmResponse = "Error: \(error.localizedDescription)"
            showingResponse = true
        }
        
        isAnalyzing = false
    }
    
    private func analyzeWithLLM(svgData: String) async throws -> String {
        // Choose your LLM provider
        // return try await sendToOpenAI(svgData: svgData)
        // return try await sendToClaude(svgData: svgData)
        // return try await sendToGemini(svgData: svgData)
        
        // For now, return a placeholder
        return "LLM analysis will appear here"
    }
}
```

## API Key Management

**Never hardcode API keys!** Use secure storage:

### Using Keychain

```swift
import Security

class KeychainHelper {
    static func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        
        return value
    }
}

// Usage
KeychainHelper.save(key: "openai_api_key", value: "sk-...")
let apiKey = KeychainHelper.load(key: "openai_api_key")
```

### Using Environment Variables (Development)

```swift
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
```

### Using Configuration File (Not Recommended)

Create a `Config.plist` and add to `.gitignore`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>OPENAI_API_KEY</key>
    <string>your-key-here</string>
</dict>
</plist>
```

## Error Handling

Implement robust error handling:

```swift
enum LLMError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case rateLimitExceeded
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your credentials."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received invalid response from server."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error: HTTP \(code)"
        }
    }
}
```

## Prompt Engineering

### For Software Spec Generation

```swift
let prompt = """
You are a software architect. Analyze this user interface sketch and:

1. Identify all UI components (buttons, text fields, containers)
2. Describe the layout and structure
3. Suggest a component hierarchy
4. Provide implementation recommendations
5. List any accessibility considerations

SVG Drawing:
\(svgData)

Please provide a detailed software specification.
"""
```

### For Diagram Analysis

```swift
let prompt = """
Analyze this technical diagram and:

1. Identify the type of diagram (flowchart, architecture, UML, etc.)
2. List all entities/components shown
3. Describe relationships and connections
4. Explain the overall system or process
5. Suggest improvements or potential issues

SVG Drawing:
\(svgData)
"""
```

### For General Sketch Analysis

```swift
let prompt = """
Analyze this freehand sketch and provide:

1. Description of what is drawn
2. Interpretation of the user's intent
3. Suggestions for formalization (turning sketch into proper diagram/spec)
4. Questions to clarify ambiguous parts

SVG Drawing:
\(svgData)
"""
```

## Testing LLM Integration

### Unit Tests

```swift
import XCTest

class LLMIntegrationTests: XCTestCase {
    func testSVGExport() {
        let model = DrawingModel()
        model.startStroke(at: CGPoint(x: 0, y: 0))
        model.addPoint(CGPoint(x: 10, y: 10))
        model.endStroke()
        
        let svg = model.exportToSVG()
        
        XCTAssertTrue(svg.contains("<svg"))
        XCTAssertTrue(svg.contains("<path"))
        XCTAssertTrue(svg.contains("</svg>"))
    }
    
    func testJSONExport() {
        let model = DrawingModel()
        model.startStroke(at: CGPoint(x: 0, y: 0))
        model.addPoint(CGPoint(x: 10, y: 10))
        model.endStroke()
        
        let json = model.exportToJSON()
        
        XCTAssertNotNil(json)
        XCTAssertTrue(json!.contains("points"))
    }
}
```

### Mock LLM for Testing

```swift
class MockLLMService {
    func analyze(svgData: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return mock response
        return """
        Analysis: This drawing contains 3 strokes forming a simple shape.
        Recommendation: Could be formalized as a triangle component.
        """
    }
}
```

## Best Practices

1. **Validate before sending**: Check if drawing has content
2. **Show loading state**: Display progress while analyzing
3. **Handle failures gracefully**: Show clear error messages
4. **Cache responses**: Avoid re-analyzing same drawing
5. **Rate limiting**: Respect API rate limits
6. **User consent**: Ask before sending data to external services
7. **Privacy**: Inform users where their data goes
8. **Cost awareness**: Display API usage/costs if applicable

## Performance Optimization

### Reduce SVG Size

```swift
func optimizeSVG(svg: String) -> String {
    // Remove unnecessary whitespace
    var optimized = svg.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    
    // Round coordinates to 2 decimal places
    // Reduces file size without noticeable quality loss
    
    return optimized
}
```

### Batch Processing

For multiple drawings:

```swift
func analyzeDrawings(_ svgs: [String]) async throws -> [String] {
    try await withThrowingTaskGroup(of: (Int, String).self) { group in
        for (index, svg) in svgs.enumerated() {
            group.addTask {
                let result = try await self.analyzeWithLLM(svgData: svg)
                return (index, result)
            }
        }
        
        var results = [String](repeating: "", count: svgs.count)
        for try await (index, result) in group {
            results[index] = result
        }
        return results
    }
}
```

## Security Considerations

1. **TLS/HTTPS Only**: Never send data over unencrypted connections
2. **API Key Rotation**: Regularly rotate API keys
3. **Input Validation**: Validate SVG before sending
4. **Output Sanitization**: Sanitize LLM responses before displaying
5. **User Data**: Don't log or store sensitive drawings without consent
6. **Error Messages**: Don't expose internal details in error messages

## Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Anthropic Claude API](https://docs.anthropic.com)
- [Google Gemini API](https://ai.google.dev/docs)
- [SVG Specification](https://www.w3.org/TR/SVG2/)
- [iOS URLSession Guide](https://developer.apple.com/documentation/foundation/urlsession)
