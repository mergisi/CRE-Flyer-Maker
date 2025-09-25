//
//  PDFPreviewView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: UIViewRepresentable {
    let pdfData: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemGray6
        
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(data: pdfData) {
            uiView.document = document
        }
    }
}

struct PDFViewerScreen: View {
    let pdfData: Data
    let fileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingSaveAlert = false
    @State private var saveError: String?
    
    var body: some View {
        NavigationStack {
            PDFPreviewView(pdfData: pdfData)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(fileName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(AppColors.primaryBlue)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                savePDFToDocuments()
                            }) {
                                Label("Save to Files", systemImage: "folder")
                            }
                            
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let pdfURL = savePDFTemporarily() {
                        ActivityViewController(items: [pdfURL])
                    }
                }
                .alert("Save PDF", isPresented: $showingSaveAlert) {
                    Button("OK") {}
                } message: {
                    if let error = saveError {
                        Text("Failed to save: \(error)")
                    } else {
                        Text("PDF saved successfully to Documents folder")
                    }
                }
        }
    }
    
    private func savePDFToDocuments() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfPath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: pdfPath)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
        
        showingSaveAlert = true
    }
    
    private func savePDFTemporarily() -> URL? {
        let tempPath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: tempPath)
            return tempPath
        } catch {
            print("Failed to save PDF temporarily: \(error)")
            return nil
        }
    }
}

// Simple UIActivityViewController wrapper for PDFViewerScreen
struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
