//
//  ShareManager.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import Foundation
import UIKit
import SwiftUI

class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    // MARK: - Share PDF
    func sharePDF(data: Data, fileName: String, completion: @escaping (Bool, String?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            
            DispatchQueue.main.async {
                self.presentShareSheet(items: [tempURL], completion: completion)
            }
        } catch {
            completion(false, "Failed to prepare PDF for sharing")
        }
    }
    
    // MARK: - Share QR Code
    func shareQRCode(for property: Property, completion: @escaping (Bool, String?) -> Void) {
        let qrGenerator = QRCodeGenerator.shared
        let qrContent = qrGenerator.generatePropertyQRContent(for: property)
        
        guard let qrImage = qrGenerator.generateQRCode(from: qrContent, size: CGSize(width: 500, height: 500)) else {
            completion(false, "Failed to generate QR code")
            return
        }
        
        let message = """
        Check out this property:
        \(property.title)
        \(property.formattedPrice)
        
        Scan the QR code for more details!
        """
        
        DispatchQueue.main.async {
            self.presentShareSheet(items: [message, qrImage], completion: completion)
        }
    }
    
    // MARK: - Share to WhatsApp
    func shareToWhatsApp(property: Property, completion: @escaping (Bool, String?) -> Void) {
        let message = """
        🏢 *\(property.title)*
        
        📍 \(property.address)
        💰 \(property.formattedPrice)
        📏 \(property.formattedSize)
        🏗️ \(property.propertyType.displayName)
        
        \(property.description.isEmpty ? "" : "📝 \(property.description)\n")
        Contact: \(property.brokerInfo.name)
        📞 \(property.brokerInfo.phone)
        ✉️ \(property.brokerInfo.email)
        
        View more: \(QRCodeGenerator.shared.generateTrackingURL(for: property.id))
        """
        
        // Check if WhatsApp is installed
        guard let whatsappURL = URL(string: "whatsapp://send?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
              UIApplication.shared.canOpenURL(whatsappURL) else {
            // Fallback to regular share
            presentShareSheet(items: [message], completion: completion)
            return
        }
        
        UIApplication.shared.open(whatsappURL) { success in
            if success {
                completion(true, "Shared to WhatsApp")
            } else {
                completion(false, "Failed to open WhatsApp")
            }
        }
    }
    
    // MARK: - Copy Link
    func copyPropertyLink(for property: Property) -> (Bool, String) {
        let trackingURL = QRCodeGenerator.shared.generateTrackingURL(for: property.id)
        UIPasteboard.general.string = trackingURL
        return (true, "Link copied to clipboard")
    }
    
    // MARK: - Copy Property Details
    func copyPropertyDetails(for property: Property) -> (Bool, String) {
        let details = """
        \(property.title)
        
        Address: \(property.address)
        Price: \(property.formattedPrice)
        Size: \(property.formattedSize)
        Type: \(property.propertyType.displayName)
        
        \(property.description.isEmpty ? "" : "Description:\n\(property.description)\n\n")
        Contact Information:
        \(property.brokerInfo.name)
        Phone: \(property.brokerInfo.phone)
        Email: \(property.brokerInfo.email)
        \(property.brokerInfo.company.isEmpty ? "" : "Company: \(property.brokerInfo.company)")
        
        More info: \(QRCodeGenerator.shared.generateTrackingURL(for: property.id))
        """
        
        UIPasteboard.general.string = details
        return (true, "Property details copied to clipboard")
    }
    
    // MARK: - Email Share
    func shareViaEmail(property: Property, pdfData: Data?, completion: @escaping (Bool, String?) -> Void) {
        let subject = "Property Listing: \(property.title)"
        let body = """
        <html>
        <body>
        <h2>\(property.title)</h2>
        <p><strong>Price:</strong> \(property.formattedPrice)<br>
        <strong>Size:</strong> \(property.formattedSize)<br>
        <strong>Type:</strong> \(property.propertyType.displayName)<br>
        <strong>Address:</strong> \(property.address)</p>
        
        <p>\(property.description)</p>
        
        <p><strong>Contact Information:</strong><br>
        \(property.brokerInfo.name)<br>
        \(property.brokerInfo.phone)<br>
        \(property.brokerInfo.email)</p>
        
        <p>View more details: <a href="\(QRCodeGenerator.shared.generateTrackingURL(for: property.id))">Click here</a></p>
        </body>
        </html>
        """
        
        if let emailURL = createEmailURL(to: "", subject: subject, body: body) {
            UIApplication.shared.open(emailURL) { success in
                completion(success, success ? "Email opened" : "Failed to open email")
            }
        } else {
            completion(false, "Failed to create email")
        }
    }
    
    // MARK: - Private Methods
    private func presentShareSheet(items: [Any], completion: @escaping (Bool, String?) -> Void) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Exclude certain activity types if needed
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        // Set completion handler
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                let message = self.getSuccessMessage(for: activityType)
                completion(true, message)
            } else if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(false, nil)
            }
        }
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func createEmailURL(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        return URL(string: urlString)
    }
    
    private func getSuccessMessage(for activityType: UIActivity.ActivityType?) -> String {
        guard let activityType = activityType else {
            return "Shared successfully"
        }
        
        switch activityType {
        case .mail:
            return "Sent via email"
        case .message:
            return "Sent via message"
        case .airDrop:
            return "Sent via AirDrop"
        case .copyToPasteboard:
            return "Copied to clipboard"
        case .saveToCameraRoll:
            return "Saved to photos"
        case .print:
            return "Sent to printer"
        default:
            if activityType.rawValue.contains("WhatsApp") {
                return "Shared to WhatsApp"
            }
            return "Shared successfully"
        }
    }
}
