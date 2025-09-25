//
//  FlyerGeneratorView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI
import PDFKit

struct FlyerGeneratorView: View {
    let property: Property
    @Environment(\.dismiss) private var dismiss
    
    @State private var isGenerating = true
    @State private var generationProgress: Double = 0.0
    @State private var generationStatus = "Preparing flyer..."
    @State private var pdfData: Data?
    @State private var generationError: String?
    @State private var showingPDFPreview = false
    @State private var showingShareOptions = false
    @State private var toast: Toast?
    
    private let pdfGenerator = PDFGenerator.shared
    private let shareManager = ShareManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isGenerating {
                    // Loading State
                    VStack(spacing: 30) {
                        // Animated Icon
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: generationProgress)
                                .stroke(AppColors.primaryBlue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.easeInOut(duration: 0.5), value: generationProgress)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.primaryBlue)
                                .scaleEffect(isGenerating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isGenerating)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Generating Flyer")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(generationStatus)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Progress Steps
                        VStack(alignment: .leading, spacing: 12) {
                            ProgressStep(title: "Processing image", isComplete: generationProgress > 0.25)
                            ProgressStep(title: "Generating QR code", isComplete: generationProgress > 0.5)
                            ProgressStep(title: "Creating PDF layout", isComplete: generationProgress > 0.75)
                            ProgressStep(title: "Finalizing document", isComplete: generationProgress >= 1.0)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                } else if let error = generationError {
                    // Error State
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Generation Failed")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            generateFlyer()
                        }) {
                            Label("Try Again", systemImage: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(AppColors.primaryBlue)
                                .cornerRadius(25)
                        }
                    }
                } else if pdfData != nil {
                    // Success State
                    VStack(spacing: 30) {
                        // Success Animation
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .scaleEffect(1.1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: pdfData != nil)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Flyer Generated!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your property flyer is ready")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingPDFPreview = true
                            }) {
                                Label("View PDF", systemImage: "eye")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primaryBlue)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingShareOptions = true
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("Generate Flyer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                generateFlyer()
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let pdfData = pdfData {
                    PDFViewerScreen(
                        pdfData: pdfData,
                        fileName: "\(property.title.replacingOccurrences(of: " ", with: "_"))_Flyer.pdf"
                    )
                }
            }
            .sheet(isPresented: $showingShareOptions) {
                if let pdfData = pdfData {
                    ShareOptionsView(property: property, pdfData: pdfData)
                }
            }
            .toast($toast)
        }
    }
    
    private func generateFlyer() {
        isGenerating = true
        generationError = nil
        generationProgress = 0.0
        
        // Simulate progress updates
        DispatchQueue.main.async {
            withAnimation {
                generationProgress = 0.25
                generationStatus = "Processing image..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                generationProgress = 0.5
                generationStatus = "Generating QR code..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                generationProgress = 0.75
                generationStatus = "Creating PDF layout..."
            }
        }
        
        // Generate PDF
        DispatchQueue.global(qos: .userInitiated).async {
            let generatedPDF = pdfGenerator.generateFlyer(for: property)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    generationProgress = 1.0
                    generationStatus = "Finalizing document..."
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        if let pdf = generatedPDF {
                            self.pdfData = pdf
                            self.isGenerating = false
                            savePDFToDocuments(pdf)
                        } else {
                            self.generationError = "Failed to generate PDF. Please try again."
                            self.isGenerating = false
                        }
                    }
                }
            }
        }
    }
    
    private func savePDFToDocuments(_ data: Data) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(property.title.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970).pdf"
        let pdfPath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try data.write(to: pdfPath)
            print("PDF saved to: \(pdfPath)")
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }
}

struct ProgressStep: View {
    let title: String
    let isComplete: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : Color(.systemGray3))
                .font(.system(size: 20))
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(isComplete ? .primary : .secondary)
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: isComplete)
    }
}
