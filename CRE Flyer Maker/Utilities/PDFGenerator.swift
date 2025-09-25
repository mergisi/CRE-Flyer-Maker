//
//  PDFGenerator.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    static let shared = PDFGenerator()
    
    private init() {}
    
    // Page dimensions for 8.5 x 11 inches at 72 DPI
    private let pageWidth: CGFloat = 612  // 8.5 * 72
    private let pageHeight: CGFloat = 792 // 11 * 72
    private let margin: CGFloat = 36      // 0.5 inch margins
    
    /// Generates a PDF flyer for a property
    /// - Parameter property: The property to generate a flyer for
    /// - Returns: PDF data if successful, nil otherwise
    func generateFlyer(for property: Property) -> Data? {
        // Create PDF renderer with 8.5x11 inch page
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            // Begin PDF page
            context.beginPage()
            
            // Draw content
            drawHeader(property: property, in: context.cgContext, at: CGPoint(x: margin, y: margin))
            
            let imageBottom = drawPropertyImage(property: property, in: context.cgContext, at: CGPoint(x: margin, y: 120))
            
            let detailsBottom = drawPropertyDetails(property: property, in: context.cgContext, at: CGPoint(x: margin, y: imageBottom + 30))
            
            let brokerBottom = drawBrokerInfo(property: property, in: context.cgContext, at: CGPoint(x: margin, y: detailsBottom + 30))
            
            drawFooter(property: property, in: context.cgContext)
        }
        
        return data
    }
    
    private func drawHeader(property: Property, in context: CGContext, at point: CGPoint) {
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(AppColors.darkGray),
            .paragraphStyle: titleParagraphStyle
        ]
        
        let title = property.title
        let titleRect = CGRect(x: margin, y: point.y, width: pageWidth - (margin * 2), height: 40)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Draw property type badge
        let typeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(AppColors.primaryBlue),
            .paragraphStyle: titleParagraphStyle
        ]
        
        let typeRect = CGRect(x: margin, y: point.y + 45, width: pageWidth - (margin * 2), height: 20)
        property.propertyType.displayName.uppercased().draw(in: typeRect, withAttributes: typeAttributes)
    }
    
    private func drawPropertyImage(property: Property, in context: CGContext, at point: CGPoint) -> CGFloat {
        guard let imageData = property.imageData,
              let image = UIImage(data: imageData) else {
            return point.y
        }
        
        // Calculate image dimensions (maintain aspect ratio)
        let maxImageWidth = pageWidth - (margin * 2)
        let maxImageHeight: CGFloat = 300
        
        let imageAspectRatio = image.size.width / image.size.height
        var imageWidth = maxImageWidth
        var imageHeight = imageWidth / imageAspectRatio
        
        if imageHeight > maxImageHeight {
            imageHeight = maxImageHeight
            imageWidth = imageHeight * imageAspectRatio
        }
        
        // Center the image horizontally
        let imageX = (pageWidth - imageWidth) / 2
        let imageRect = CGRect(x: imageX, y: point.y, width: imageWidth, height: imageHeight)
        
        // Draw the image
        image.draw(in: imageRect)
        
        return point.y + imageHeight
    }
    
    private func drawPropertyDetails(property: Property, in context: CGContext, at point: CGPoint) -> CGFloat {
        var currentY = point.y
        
        let headingAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor(AppColors.darkGray)
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(AppColors.mediumGray)
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(AppColors.primaryBlue)
        ]
        
        // Draw price and size in two columns
        let columnWidth = (pageWidth - (margin * 2) - 20) / 2
        
        // Price
        "PRICE".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: headingAttributes)
        property.formattedPrice.draw(at: CGPoint(x: point.x, y: currentY + 20), withAttributes: valueAttributes)
        
        // Size
        "SIZE".draw(at: CGPoint(x: point.x + columnWidth + 20, y: currentY), withAttributes: headingAttributes)
        property.formattedSize.draw(at: CGPoint(x: point.x + columnWidth + 20, y: currentY + 20), withAttributes: valueAttributes)
        
        currentY += 60
        
        // Address
        if !property.address.isEmpty {
            "ADDRESS".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: headingAttributes)
            currentY += 20
            
            let addressRect = CGRect(x: point.x, y: currentY, width: pageWidth - (margin * 2), height: 40)
            property.address.draw(in: addressRect, withAttributes: bodyAttributes)
            currentY += 40
        }
        
        // Description
        if !property.description.isEmpty {
            currentY += 10
            "DESCRIPTION".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: headingAttributes)
            currentY += 20
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            var descAttributes = bodyAttributes
            descAttributes[.paragraphStyle] = paragraphStyle
            
            let descriptionRect = CGRect(x: point.x, y: currentY, width: pageWidth - (margin * 2), height: 200)
            let boundingRect = property.description.boundingRect(
                with: CGSize(width: pageWidth - (margin * 2), height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: descAttributes,
                context: nil
            )
            
            property.description.draw(in: CGRect(x: point.x, y: currentY, width: pageWidth - (margin * 2), height: boundingRect.height), withAttributes: descAttributes)
            currentY += min(boundingRect.height, 200)
        }
        
        return currentY
    }
    
    private func drawBrokerInfo(property: Property, in context: CGContext, at point: CGPoint) -> CGFloat {
        var currentY = point.y
        
        let headingAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor(AppColors.darkGray)
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(AppColors.mediumGray)
        ]
        
        // Draw broker section header
        "CONTACT INFORMATION".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: headingAttributes)
        currentY += 25
        
        // Draw broker details
        if !property.brokerInfo.name.isEmpty {
            property.brokerInfo.name.draw(at: CGPoint(x: point.x, y: currentY), withAttributes: bodyAttributes)
            currentY += 20
        }
        
        if !property.brokerInfo.company.isEmpty {
            property.brokerInfo.company.draw(at: CGPoint(x: point.x, y: currentY), withAttributes: bodyAttributes)
            currentY += 20
        }
        
        if !property.brokerInfo.phone.isEmpty {
            "Phone: \(property.brokerInfo.phone)".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: bodyAttributes)
            currentY += 20
        }
        
        if !property.brokerInfo.email.isEmpty {
            "Email: \(property.brokerInfo.email)".draw(at: CGPoint(x: point.x, y: currentY), withAttributes: bodyAttributes)
            currentY += 20
        }
        
        return currentY
    }
    
    
    private func drawFooter(property: Property, in context: CGContext) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(AppColors.mediumGray)
        ]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateString = "Generated on \(formatter.string(from: Date()))"
        
        let footerSize = dateString.size(withAttributes: footerAttributes)
        let footerX = (pageWidth - footerSize.width) / 2
        let footerY = pageHeight - margin - footerSize.height
        
        dateString.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
        
        // Draw app branding
        let brandingText = "Created with CRE Flyer Maker"
        let brandingSize = brandingText.size(withAttributes: footerAttributes)
        let brandingX = (pageWidth - brandingSize.width) / 2
        
        brandingText.draw(at: CGPoint(x: brandingX, y: footerY - 15), withAttributes: footerAttributes)
    }
}
