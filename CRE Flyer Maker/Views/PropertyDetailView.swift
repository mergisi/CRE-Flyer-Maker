//
//  PropertyDetailView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingShareOptions = false
    @State private var showingDeleteAlert = false
    @State private var showingFlyerGenerator = false
    @State private var toast: Toast?
    
    private let userDefaultsManager = UserDefaultsManager.shared
    private let shareManager = ShareManager.shared
    
    private var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: property.createdDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Property Image
                if let imageData = property.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 400)
                        .background(Color.black)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemGray5))
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.system(size: 60))
                                .foregroundColor(Color(.systemGray3))
                        )
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text(property.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Label(property.propertyType.displayName, systemImage: "building.2")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColors.primaryBlue.opacity(0.1))
                                .foregroundColor(AppColors.primaryBlue)
                                .clipShape(Capsule())
                            
                            Spacer()
                        }
                    }
                    
                    // Price and Size
                    HStack(spacing: 30) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(property.formattedPrice)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryBlue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(property.formattedSize)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    // Address
                    if !property.address.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Address", systemImage: "location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(property.address)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Description
                    if !property.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(property.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Broker Information
                    if property.brokerInfo.isComplete {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Broker Information", systemImage: "person.circle")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if !property.brokerInfo.name.isEmpty {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        Text(property.brokerInfo.name)
                                            .font(.body)
                                    }
                                }
                                
                                if !property.brokerInfo.phone.isEmpty {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        Link(property.brokerInfo.phone, destination: URL(string: "tel:\(property.brokerInfo.phone.filter { $0.isNumber })")!)
                                            .font(.body)
                                    }
                                }
                                
                                if !property.brokerInfo.email.isEmpty {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        Link(property.brokerInfo.email, destination: URL(string: "mailto:\(property.brokerInfo.email)")!)
                                            .font(.body)
                                    }
                                }
                                
                                if !property.brokerInfo.company.isEmpty {
                                    HStack {
                                        Image(systemName: "building.fill")
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        Text(property.brokerInfo.company)
                                            .font(.body)
                                    }
                                }
                            }
                            .padding(.leading, 4)
                        }
                    }
                    
                    // Created Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Created")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedCreatedDate)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingFlyerGenerator = true
                        }) {
                            Label("Generate Flyer", systemImage: "doc.text.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryBlue)
                                .cornerRadius(12)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                showingShareOptions = true
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
                .foregroundColor(AppColors.primaryBlue)
            }
        }
        .sheet(isPresented: $showingEditView) {
            // Edit view to be implemented
            Text("Edit Property View - Coming Soon")
        }
        .sheet(isPresented: $showingShareOptions) {
            ShareOptionsView(property: property, pdfData: nil)
        }
        .alert("Delete Property", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteProperty()
            }
        } message: {
            Text("Are you sure you want to delete this property? This action cannot be undone.")
        }
        .sheet(isPresented: $showingFlyerGenerator) {
            FlyerGeneratorView(property: property)
        }
        .toast($toast)
    }
    
    private func deleteProperty() {
        userDefaultsManager.deleteProperty(withId: property.id)
        dismiss()
    }
}
