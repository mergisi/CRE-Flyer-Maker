//
//  ShareOptionsView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct ShareOptionsView: View {
    let property: Property
    let pdfData: Data?
    @Environment(\.dismiss) private var dismiss
    @State private var toast: Toast?
    @State private var isProcessing = false
    
    private let shareManager = ShareManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primaryBlue)
                    
                    Text("Share Property")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(property.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                
                Divider()
                
                // Share Options
                ScrollView {
                    VStack(spacing: 12) {
                        // Share PDF
                        if let pdfData = pdfData {
                            ShareOptionButton(
                                icon: "doc.fill",
                                title: "Share PDF Flyer",
                                subtitle: "Share the complete property flyer",
                                color: .red,
                                isProcessing: isProcessing
                            ) {
                                sharePDF(pdfData)
                            }
                        }
                        
                        // Share QR Code
                        ShareOptionButton(
                            icon: "qrcode",
                            title: "Share QR Code",
                            subtitle: "Share QR code with property details",
                            color: .purple,
                            isProcessing: isProcessing
                        ) {
                            shareQRCode()
                        }
                        
                        // WhatsApp
                        ShareOptionButton(
                            icon: "message.fill",
                            title: "Share via WhatsApp",
                            subtitle: "Send property details on WhatsApp",
                            color: .green,
                            isProcessing: isProcessing
                        ) {
                            shareViaWhatsApp()
                        }
                        
                        // Email
                        ShareOptionButton(
                            icon: "envelope.fill",
                            title: "Share via Email",
                            subtitle: "Send property details via email",
                            color: AppColors.primaryBlue,
                            isProcessing: isProcessing
                        ) {
                            shareViaEmail()
                        }
                        
                        // Copy Link
                        ShareOptionButton(
                            icon: "link",
                            title: "Copy Property Link",
                            subtitle: "Copy tracking link to clipboard",
                            color: .orange,
                            isProcessing: isProcessing
                        ) {
                            copyLink()
                        }
                        
                        // Copy Details
                        ShareOptionButton(
                            icon: "doc.on.doc.fill",
                            title: "Copy Property Details",
                            subtitle: "Copy all property information",
                            color: .indigo,
                            isProcessing: isProcessing
                        ) {
                            copyDetails()
                        }
                        
                        // General Share
                        ShareOptionButton(
                            icon: "square.and.arrow.up",
                            title: "More Options",
                            subtitle: "Share using other apps",
                            color: .gray,
                            isProcessing: isProcessing
                        ) {
                            shareGeneral()
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
            .toast($toast)
            .disabled(isProcessing)
        }
    }
    
    // MARK: - Share Actions
    
    private func sharePDF(_ data: Data) {
        isProcessing = true
        let fileName = "\(property.title.replacingOccurrences(of: " ", with: "_"))_Flyer.pdf"
        
        shareManager.sharePDF(data: data, fileName: fileName) { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.toast = Toast(message: message ?? "PDF shared successfully", type: .success)
                } else {
                    self.toast = Toast(message: message ?? "Failed to share PDF", type: .error)
                }
            }
        }
    }
    
    private func shareQRCode() {
        isProcessing = true
        
        shareManager.shareQRCode(for: property) { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.toast = Toast(message: message ?? "QR code shared successfully", type: .success)
                } else {
                    self.toast = Toast(message: message ?? "Failed to share QR code", type: .error)
                }
            }
        }
    }
    
    private func shareViaWhatsApp() {
        isProcessing = true
        
        shareManager.shareToWhatsApp(property: property) { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.toast = Toast(message: message ?? "Shared to WhatsApp", type: .success)
                } else {
                    self.toast = Toast(message: message ?? "Failed to share", type: .error)
                }
            }
        }
    }
    
    private func shareViaEmail() {
        isProcessing = true
        
        shareManager.shareViaEmail(property: property, pdfData: pdfData) { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.toast = Toast(message: message ?? "Email opened", type: .success)
                } else {
                    self.toast = Toast(message: message ?? "Failed to open email", type: .error)
                }
            }
        }
    }
    
    private func copyLink() {
        let (success, message) = shareManager.copyPropertyLink(for: property)
        toast = Toast(message: message, type: success ? .success : .error)
    }
    
    private func copyDetails() {
        let (success, message) = shareManager.copyPropertyDetails(for: property)
        toast = Toast(message: message, type: success ? .success : .error)
    }
    
    private func shareGeneral() {
        isProcessing = true
        
        let trackingURL = QRCodeGenerator.shared.generateTrackingURL(for: property.id)
        let shareText = """
        \(property.title)
        \(property.formattedPrice) | \(property.formattedSize)
        \(property.address)
        
        View more: \(trackingURL)
        """
        
        shareManager.sharePDF(data: shareText.data(using: .utf8)!, fileName: "property.txt") { success, message in
            DispatchQueue.main.async {
                self.isProcessing = false
                if let message = message {
                    self.toast = Toast(message: message, type: success ? .success : .error)
                }
            }
        }
    }
}

// MARK: - Share Option Button
struct ShareOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isProcessing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .disabled(isProcessing)
        .opacity(isProcessing ? 0.6 : 1.0)
    }
}
