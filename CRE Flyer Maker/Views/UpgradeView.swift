//
//  UpgradeView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedProduct: Product?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum PricingPlan {
        case yearly
        case monthly
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                closeButton
                crownIcon
                titleSection
                featuresCard
                Spacer()
                subscribeButton
            }
        }
        .onAppear {
            Task {
                await storeManager.loadProducts()
                selectedProduct = storeManager.yearlyProduct ?? storeManager.monthlyProduct
            }
        }
        .alert("Subscription", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlue.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .padding(.trailing, 20)
            .padding(.top, 10)
        }
    }
    
    private var crownIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color.yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
        .padding(.top, 20)
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Go Pro")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            Text("Create unlimited flyers & unlock all features")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var featuresCard: some View {
        VStack(spacing: 0) {
            featuresList
            pricingOptions
        }
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProFeatureRow(
                title: "Unlimited Flyers",
                subtitle: "No limits on property listings"
            )
            
            ProFeatureRow(
                title: "Advanced Analytics",
                subtitle: "Track views, scans, and engagement"
            )
            
            ProFeatureRow(
                title: "Custom Branding",
                subtitle: "Add your logo and brand colors"
            )
            
            ProFeatureRow(
                title: "Priority Support",
                subtitle: "Get help when you need it"
            )
        }
        .padding(25)
    }
    
    private var pricingOptions: some View {
        VStack(spacing: 12) {
            if storeManager.isLoading {
                ProgressView()
                    .padding()
            } else {
                if let yearlyProduct = storeManager.yearlyProduct {
                    PricingOptionView(
                        product: yearlyProduct,
                        savings: storeManager.yearlyDiscount(),
                        isSelected: selectedProduct?.id == yearlyProduct.id,
                        isBestValue: true
                    ) {
                        selectedProduct = yearlyProduct
                    }
                }
                
                if let monthlyProduct = storeManager.monthlyProduct {
                    PricingOptionView(
                        product: monthlyProduct,
                        savings: nil,
                        isSelected: selectedProduct?.id == monthlyProduct.id,
                        isBestValue: false
                    ) {
                        selectedProduct = monthlyProduct
                    }
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 25)
    }
    
    private var subscribeButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await purchaseSelectedProduct()
                }
            }) {
                HStack {
                    if storeManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                            .scaleEffect(0.8)
                    } else {
                        Text("Start Free Trial")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(14)
            }
            .disabled(storeManager.isLoading || selectedProduct == nil)
            
            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            
            // Terms of Use and Privacy Policy Links
            HStack(spacing: 20) {
                Button("Terms of Use") {
                    if let url = URL(string: "https://creflyer.app/terms-of-use.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                
                Button("Privacy Policy") {
                    if let url = URL(string: "https://creflyer.app/privacy-policy.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private func purchaseSelectedProduct() async {
        guard let product = selectedProduct else { return }
        
        let success = await storeManager.purchase(product)
        
        if success {
            alertMessage = "Welcome to CRE Flyer Maker Pro! 🎉"
            showingAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        } else if let error = storeManager.errorMessage {
            alertMessage = error
            showingAlert = true
        }
    }
}

struct ProFeatureRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct PricingOptionView: View {
    let product: Product?
    let savings: String?
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void
    
    private var price: String {
        product?.displayPrice ?? "$0.00"
    }
    
    private var period: String {
        guard let product = product else { return "per month" }
        return product.isYearly ? "per year" : "per month"
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Main content
                pricingContent
                
                // Best Value badge
                if isBestValue {
                    bestValueBadge
                }
            }
        }
    }
    
    private var pricingContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 8) {
                    Text(price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(period)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                if let savings = savings {
                    Text(savings)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Radio button
            radioButton
        }
        .padding(20)
        .background(optionBackground)
    }
    
    private var radioButton: some View {
        Circle()
            .stroke(isSelected ? AppColors.primaryBlue : Color.gray.opacity(0.3), lineWidth: 2)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .fill(AppColors.primaryBlue)
                    .frame(width: 14, height: 14)
                    .opacity(isSelected ? 1 : 0)
            )
    }
    
    private var optionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected ? AppColors.primaryBlue : Color.gray.opacity(0.3),
                lineWidth: isSelected ? 2 : 1
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primaryBlue.opacity(0.05) : Color.white)
            )
    }
    
    private var bestValueBadge: some View {
        Text("BEST VALUE")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.orange)
            .cornerRadius(8)
            .offset(x: -10, y: -10)
    }
}

#Preview {
    UpgradeView()
}
