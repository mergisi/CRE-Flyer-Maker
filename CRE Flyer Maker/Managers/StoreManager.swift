//
//  StoreManager.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/25/25.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var subscriptionGroupStatus: Product.SubscriptionInfo.RenewalState?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Product IDs - these should match what you create in App Store Connect
    private let productIds = [
        "cre_flyer_maker_pro_monthly",
        "cre_flyer_maker_pro_yearly"
    ]
    
    private var updates: Task<Void, Never>? = nil
    
    private init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Store Setup
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: productIds)
            products = storeProducts.sorted { product1, product2 in
                // Sort yearly first (best value)
                if product1.id.contains("yearly") && product2.id.contains("monthly") {
                    return true
                } else if product1.id.contains("monthly") && product2.id.contains("yearly") {
                    return false
                }
                return product1.price < product2.price
            }
            
            await updateSubscriptionStatus()
            
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Methods
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
                isLoading = false
                return true
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                isLoading = false
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Failed to restore purchases: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let subscription = products.first(where: { $0.id == transaction.productID }) {
                    purchasedSubscriptions.append(subscription)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        self.purchasedSubscriptions = purchasedSubscriptions
        
        // Update subscription group status
        for subscription in purchasedSubscriptions {
            if let statuses = try? await subscription.subscription?.status,
               let status = statuses.first {
                let renewalInfo = try? checkVerified(status.renewalInfo)
                subscriptionGroupStatus = renewalInfo?.renewalState
                break
            }
        }
    }
    
    // MARK: - Subscription Info
    
    var hasActiveSubscription: Bool {
        !purchasedSubscriptions.isEmpty
    }
    
    var isProUser: Bool {
        hasActiveSubscription
    }
    
    var currentSubscription: Product? {
        purchasedSubscriptions.first
    }
    
    var subscriptionExpirationDate: Date? {
        guard let subscription = currentSubscription,
              let subscriptionInfo = subscription.subscription else {
            return nil
        }
        
        // This is a simplified version - in reality you'd need to check the subscription status
        return subscriptionInfo.subscriptionPeriod.value == 1 ? 
            Calendar.current.date(byAdding: .month, value: 1, to: Date()) :
            Calendar.current.date(byAdding: .year, value: 1, to: Date())
    }
    
    // MARK: - Product Information
    
    var monthlyProduct: Product? {
        products.first { $0.id.contains("monthly") }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id.contains("yearly") }
    }
    
    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }
    
    func yearlyDiscount() -> String? {
        guard let monthly = monthlyProduct,
              let yearly = yearlyProduct else {
            return nil
        }
        
        let monthlyYearlyPrice = monthly.price * Decimal(12)
        let discount = (monthlyYearlyPrice - yearly.price) / monthlyYearlyPrice * Decimal(100)
        
        return String(format: "%.0f%% OFF", NSDecimalNumber(decimal: discount).doubleValue)
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Updates
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                do {
                    let transaction = try checkVerified(verificationResult)
                    await updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error, LocalizedError {
    case failedVerification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Helper Extensions

extension Product {
    var isMonthly: Bool {
        id.contains("monthly")
    }
    
    var isYearly: Bool {
        id.contains("yearly")
    }
}

// MARK: - UserDefaults Extension for Pro Features

extension UserDefaults {
    private enum Keys {
        static let isProUser = "isProUser"
        static let subscriptionExpirationDate = "subscriptionExpirationDate"
    }
    
    var isProUser: Bool {
        get { bool(forKey: Keys.isProUser) }
        set { set(newValue, forKey: Keys.isProUser) }
    }
    
    var subscriptionExpirationDate: Date? {
        get { object(forKey: Keys.subscriptionExpirationDate) as? Date }
        set { set(newValue, forKey: Keys.subscriptionExpirationDate) }
    }
}
