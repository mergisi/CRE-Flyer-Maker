//
//  FlyerDetailView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct FlyerDetailView: View {
    let propertyImage: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var propertyAddress = ""
    @State private var propertyPrice = ""
    @State private var propertySize = ""
    @State private var propertyType = "Office"
    @State private var propertyDescription = ""
    @State private var brokerName = ""
    @State private var brokerPhone = ""
    @State private var brokerEmail = ""
    @State private var companyName = ""
    
    let propertyTypes = ["Office", "Retail", "Industrial", "Multifamily", "Mixed-Use", "Land", "Other"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Property Image Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Property Photo")
                            .font(.headline)
                            .foregroundColor(AppColors.darkGray)
                        
                        Image(uiImage: propertyImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Property Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Property Information")
                            .font(.headline)
                            .foregroundColor(AppColors.darkGray)
                        
                        CustomTextField(
                            title: "Property Address",
                            text: $propertyAddress,
                            placeholder: "123 Main Street, City, State"
                        )
                        
                        HStack(spacing: 12) {
                            CustomTextField(
                                title: "Price",
                                text: $propertyPrice,
                                placeholder: "$0",
                                keyboardType: .decimalPad
                            )
                            
                            CustomTextField(
                                title: "Size (sq ft)",
                                text: $propertySize,
                                placeholder: "0",
                                keyboardType: .numberPad
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Property Type")
                                .font(.caption)
                                .foregroundColor(AppColors.mediumGray)
                            
                            Picker("Property Type", selection: $propertyType) {
                                ForEach(propertyTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(AppColors.mediumGray)
                            
                            TextEditor(text: $propertyDescription)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Broker Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Broker Information")
                            .font(.headline)
                            .foregroundColor(AppColors.darkGray)
                        
                        CustomTextField(
                            title: "Broker Name",
                            text: $brokerName,
                            placeholder: "John Doe"
                        )
                        
                        CustomTextField(
                            title: "Phone Number",
                            text: $brokerPhone,
                            placeholder: "(555) 123-4567",
                            keyboardType: .phonePad
                        )
                        
                        CustomTextField(
                            title: "Email",
                            text: $brokerEmail,
                            placeholder: "broker@example.com",
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            title: "Company Name",
                            text: $companyName,
                            placeholder: "ABC Realty"
                        )
                    }
                    
                    // Generate Flyer Button
                    Button(action: {
                        // Generate flyer action will be implemented later
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Generate Flyer")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primaryBlue)
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(AppColors.lightGray)
            .navigationTitle("Create Flyer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.mediumGray)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
