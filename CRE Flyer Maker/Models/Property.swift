//
//  Property.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import Foundation
import UIKit

// MARK: - Property Type
enum PropertyType: String, CaseIterable, Codable {
    case office = "Office"
    case retail = "Retail"
    case industrial = "Industrial"
    case land = "Land"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Size Unit
enum SizeUnit: String, CaseIterable, Codable {
    case sqft = "sq ft"
    case sqm = "sq m"
    
    var displayName: String {
        return self.rawValue
    }
    
    func convert(value: Double, to unit: SizeUnit) -> Double {
        if self == unit {
            return value
        }
        
        switch (self, unit) {
        case (.sqft, .sqm):
            return value * 0.092903 // Convert sq ft to sq m
        case (.sqm, .sqft):
            return value * 10.7639 // Convert sq m to sq ft
        default:
            return value
        }
    }
}

// MARK: - Price Type
enum PriceType: String, CaseIterable, Codable {
    case sale = "For Sale"
    case lease = "For Lease"
    
    var displayName: String {
        return self.rawValue
    }
    
    var pricePrefix: String {
        switch self {
        case .sale:
            return "$"
        case .lease:
            return "$"
        }
    }
    
    var priceSuffix: String {
        switch self {
        case .sale:
            return ""
        case .lease:
            return "/month"
        }
    }
}

// MARK: - Broker Info
struct BrokerInfo: Codable, Equatable {
    var name: String
    var phone: String
    var email: String
    var company: String
    
    init(name: String = "", phone: String = "", email: String = "", company: String = "") {
        self.name = name
        self.phone = phone
        self.email = email
        self.company = company
    }
    
    var isComplete: Bool {
        return !name.isEmpty && !phone.isEmpty && !email.isEmpty
    }
}

// MARK: - Property Model
struct Property: Codable, Identifiable {
    let id: UUID
    let title: String
    let propertyType: PropertyType
    let size: Double
    let sizeUnit: SizeUnit
    let price: Double
    let priceType: PriceType
    let address: String
    let description: String
    let brokerInfo: BrokerInfo
    let imageData: Data?
    let createdDate: Date
    let updatedDate: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        propertyType: PropertyType,
        size: Double,
        sizeUnit: SizeUnit,
        price: Double,
        priceType: PriceType,
        address: String,
        description: String,
        brokerInfo: BrokerInfo,
        imageData: Data? = nil,
        createdDate: Date = Date(),
        updatedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.propertyType = propertyType
        self.size = size
        self.sizeUnit = sizeUnit
        self.price = price
        self.priceType = priceType
        self.address = address
        self.description = description
        self.brokerInfo = brokerInfo
        self.imageData = imageData
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        let formattedAmount = formatter.string(from: NSNumber(value: price)) ?? "$0"
        return "\(formattedAmount)\(priceType.priceSuffix)"
    }
    
    var formattedSize: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedValue = formatter.string(from: NSNumber(value: size)) ?? "0"
        return "\(formattedValue) \(sizeUnit.displayName)"
    }
}
