//
//  ContentView.swift
//  VectorSketchApp
//
//  Main view with drawing canvas and controls
//

import SwiftUI

struct ContentView: View {
    @StateObject private var drawingModel = DrawingModel()
    @State private var showingSVGExport = false
    @State private var exportedSVG = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Drawing Canvas
                DrawingCanvasView(drawingModel: drawingModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                
                // Control Panel
                HStack(spacing: 20) {
                    Button(action: {
                        drawingModel.clear()
                    }) {
                        Label("Clear", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        exportedSVG = drawingModel.exportToSVG()
                        showingSVGExport = true
                    }) {
                        Label("Export SVG", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        sendToLLM()
                    }) {
                        Label("Send to LLM", systemImage: "brain")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .sheet(isPresented: $showingSVGExport) {
            SVGExportView(svgContent: exportedSVG)
        }
    }
    
    private func sendToLLM() {
        Task {
            let svg = drawingModel.exportToSVG()
            // Placeholder for LLM integration
            // In a real implementation, this would send the SVG to an LLM API
            print("Sending to LLM:")
            print(svg)
            // Example: await sendToOpenAI(svgData: svg)
        }
    }
}

struct SVGExportView: View {
    let svgContent: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(svgContent)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("SVG Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        UIPasteboard.general.string = svgContent
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
