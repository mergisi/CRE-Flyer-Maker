//
//  HomeView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct HomeView: View {
    @State private var properties: [Property] = []
    @State private var showingCameraView = false
    @State private var selectedProperty: Property?
    @State private var isRefreshing = false
    @State private var showingUpgradeAlert = false
    @State private var showingUpgradeView = false
    
    @AppStorage("flyersCreated") private var flyersCreated = 0
    @StateObject private var storeManager = StoreManager.shared
    private let freeLimit = 2
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Free tier banner
                if flyersCreated < freeLimit {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.white)
                        Text("Free: \(freeLimit - flyersCreated) flyers remaining")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryBlue)
                }
                
                ZStack {
                    // Main Content
                    if properties.isEmpty {
                        // Empty State View
                        EmptyStateView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGroupedBackground))
                    } else {
                        // Properties List
                        List {
                            ForEach(properties) { property in
                                NavigationLink(destination: PropertyDetailView(property: property)) {
                                    PropertyRowView(property: property)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete(perform: deleteProperties)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            await refreshProperties()
                        }
                    }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            if !storeManager.isProUser && flyersCreated >= freeLimit {
                                showingUpgradeAlert = true
                            } else {
                                showingCameraView = true
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
                } // Close ZStack
            }
            .navigationTitle("Properties")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !properties.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingCameraView) {
                CameraView()
                    .onDisappear {
                        loadProperties()
                    }
            }
            .onAppear {
                loadProperties()
                Task {
                    await storeManager.loadProducts()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                loadProperties()
            }
            .alert("Upgrade to Pro", isPresented: $showingUpgradeAlert) {
                Button("Maybe Later", role: .cancel) {}
                Button("Upgrade") {
                    showingUpgradeView = true
                }
            } message: {
                Text("Upgrade to Pro for unlimited flyers")
            }
            .sheet(isPresented: $showingUpgradeView) {
                UpgradeView()
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadProperties() {
        withAnimation {
            properties = userDefaultsManager.loadProperties().sorted { $0.createdDate > $1.createdDate }
        }
    }
    
    private func refreshProperties() async {
        // Simulate network delay for refresh animation
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            loadProperties()
        }
    }
    
    private func deleteProperties(at offsets: IndexSet) {
        for index in offsets {
            let property = properties[index]
            userDefaultsManager.deleteProperty(withId: property.id)
        }
        
        withAnimation {
            properties.remove(atOffsets: offsets)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.image")
                .font(.system(size: 70))
                .foregroundColor(AppColors.primaryBlue.opacity(0.5))
            
            Text("No Properties Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Create your first flyer")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Property Row View
struct PropertyRowView: View {
    let property: Property
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: property.createdDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail Image
            Group {
                if let imageData = property.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.systemGray3))
                        )
                }
            }
            
            // Property Details
            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if !property.address.isEmpty {
                    Text(property.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(formattedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(property.propertyType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.primaryBlue.opacity(0.1))
                        .foregroundColor(AppColors.primaryBlue)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryBlue)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    HomeView()
}
