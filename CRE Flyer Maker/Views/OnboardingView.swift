//
//  OnboardingView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Blue gradient background
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                
                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        emoji: "📷✨",
                        title: "Capture & Create",
                        subtitle: "Turn property photos into professional flyers in just 60 seconds",
                        isLastPage: false
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        emoji: "📊",
                        title: "Track Engagement",
                        subtitle: "See who's viewing your properties with smart QR codes and analytics",
                        isLastPage: false
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        emoji: "🚀",
                        title: "Share Instantly",
                        subtitle: "Export as PDF, save to Photos, or share with iOS's built-in sharing options",
                        isLastPage: true,
                        buttonAction: {
                            completeOnboarding()
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isLastPage: Bool
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Circular background with floating dots and emoji
            ZStack {
                // Large background circle
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 320, height: 320)
                
                // Floating dots
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .offset(x: 80, y: -100)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .offset(x: -90, y: -60)
                
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 50, height: 50)
                    .offset(x: -70, y: 80)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 35, height: 35)
                    .offset(x: 100, y: 70)
                
                // Center emoji
                Text(emoji)
                    .font(.system(size: 80))
            }
            .padding(.bottom, 60)
            
            // Title
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)
            
            // Subtitle
            Text(subtitle)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Button (only on last page)
            if isLastPage {
                VStack(spacing: 0) {
                    Button(action: {
                        buttonAction?()
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.15))
                        .padding(.horizontal, 20)
                )
            } else {
                VStack(spacing: 0) {
                    Button(action: {
                        // Continue to next page
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.15))
                        .padding(.horizontal, 20)
                )
            }
        }
    }
}

#Preview {
    OnboardingView()
}
