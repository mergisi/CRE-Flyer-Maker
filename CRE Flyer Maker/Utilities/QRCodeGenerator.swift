//
//  QRCodeGenerator.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    
    private let context = CIContext()
    
    private init() {}
    
    /// Generates a QR code image from the given string
    /// - Parameters:
    ///   - string: The string to encode in the QR code
    ///   - size: The desired size of the QR code image
    /// - Returns: UIImage of the QR code, or nil if generation fails
    func generateQRCode(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        // Create QR code filter
        let filter = CIFilter.qrCodeGenerator()
        
        // Convert string to data
        guard let data = string.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        // Set the data for the QR code
        filter.setValue(data, forKey: "inputMessage")
        
        // Set error correction level to high
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Get the output image
        guard let outputImage = filter.outputImage else {
            print("Failed to generate QR code")
            return nil
        }
        
        // Scale the image to the desired size
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert CIImage to UIImage
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            print("Failed to create CGImage")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Generates a tracking URL for a property
    /// - Parameter propertyId: The unique ID of the property
    /// - Returns: A tracking URL string
    func generateTrackingURL(for propertyId: UUID) -> String {
        // In a real app, this would point to your tracking server
        // For now, we'll create a demo URL structure
        let baseURL = "https://creflyer.app/track"
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(baseURL)/\(propertyId.uuidString)?t=\(timestamp)"
    }
    
    /// Generates property info string for QR code
    /// - Parameter property: The property to encode
    /// - Returns: A formatted string with property information
    func generatePropertyQRContent(for property: Property) -> String {
        let trackingURL = generateTrackingURL(for: property.id)
        
        // Create a structured data format that could be parsed
        let qrContent = """
        \(trackingURL)
        
        Property: \(property.title)
        Type: \(property.propertyType.displayName)
        Price: \(property.formattedPrice)
        Size: \(property.formattedSize)
        
        Contact: \(property.brokerInfo.name)
        Phone: \(property.brokerInfo.phone)
        Email: \(property.brokerInfo.email)
        """
        
        return qrContent
    }
}
