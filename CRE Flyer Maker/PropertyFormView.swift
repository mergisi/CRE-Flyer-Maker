//
//  PropertyFormView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct PropertyFormView: View {
    let propertyImage: UIImage
    @Environment(\.dismiss) private var dismiss
    
    // Property Fields
    @State private var title = ""
    @State private var propertyType: PropertyType = .office
    @State private var size = ""
    @State private var sizeUnit: SizeUnit = .sqft
    @State private var price = ""
    @State private var priceType: PriceType = .sale
    @State private var address = ""
    @State private var propertyDescription = ""
    
    // Broker Fields
    @State private var brokerName = ""
    @State private var brokerPhone = ""
    @State private var brokerEmail = ""
    @State private var brokerCompany = ""
    
    // UI State
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isKeyboardVisible = false
    @FocusState private var focusedField: Field?
    @State private var savedSuccessfully = false
    
    @AppStorage("flyersCreated") private var flyersCreated = 0
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    enum Field: Hashable {
        case title
        case size
        case price
        case address
        case description
        case brokerName
        case brokerPhone
        case brokerEmail
        case brokerCompany
    }
    
    init(propertyImage: UIImage) {
        self.propertyImage = propertyImage
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Property Image Section
                Section {
                    HStack {
                        Spacer()
                        Image(uiImage: propertyImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Property Photo")
                }
                
                // Property Information Section
                Section {
                    // Title Field (Required)
                    HStack {
                        Text("Title")
                        Spacer()
                        TextField("Property Title", text: $title)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .title)
                        Text("*")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Property Type Picker
                    Picker("Property Type", selection: $propertyType) {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    // Size with Unit Toggle
                    HStack {
                        Text("Size")
                        Spacer()
                        TextField("0", text: $size)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .focused($focusedField, equals: .size)
                        
                        Picker("Unit", selection: $sizeUnit) {
                            ForEach(SizeUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 100)
                    }
                    
                    // Price with Sale/Lease Toggle
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("0", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .focused($focusedField, equals: .price)
                        
                        Picker("Type", selection: $priceType) {
                            ForEach(PriceType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 140)
                    }
                    
                    // Address Field
                    HStack {
                        Text("Address")
                        Spacer()
                        TextField("Property Address", text: $address, axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .address)
                    }
                    
                } header: {
                    Text("Property Information")
                } footer: {
                    Text("* Required field")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // Property Description Section
                Section {
                    TextEditor(text: $propertyDescription)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
                        .overlay(
                            Group {
                                if propertyDescription.isEmpty {
                                    Text("Enter property description...")
                                        .foregroundColor(Color(.placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                } header: {
                    Text("Description")
                }
                
                // Broker Information Section
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $brokerName)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .brokerName)
                    }
                    
                    HStack {
                        Text("Phone")
                        Spacer()
                        TextField("(555) 123-4567", text: $brokerPhone)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .brokerPhone)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("email@example.com", text: $brokerEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .brokerEmail)
                    }
                    
                    HStack {
                        Text("Company")
                        Spacer()
                        TextField("Company Name", text: $brokerCompany)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .brokerCompany)
                    }
                } header: {
                    Text("Broker Information")
                } footer: {
                    Text("This information will be saved for future use")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Save Button Section
                Section {
                    Button(action: saveProperty) {
                        HStack {
                            Spacer()
                            if savedSuccessfully {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Saved Successfully")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Property")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(savedSuccessfully ? Color.green.opacity(0.1) : AppColors.primaryBlue)
                    .foregroundColor(savedSuccessfully ? .green : .white)
                }
            }
            .navigationTitle("Property Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProperty()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                    .fontWeight(.semibold)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button("Previous") {
                            focusPreviousField()
                        }
                        .disabled(!canFocusPreviousField())
                        
                        Button("Next") {
                            focusNextField()
                        }
                        .disabled(!canFocusNextField())
                        
                        Spacer()
                        
                        Button("Done") {
                            focusedField = nil
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                loadSavedBrokerInfo()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadSavedBrokerInfo() {
        if let savedBrokerInfo = userDefaultsManager.loadBrokerInfo() {
            brokerName = savedBrokerInfo.name
            brokerPhone = savedBrokerInfo.phone
            brokerEmail = savedBrokerInfo.email
            brokerCompany = savedBrokerInfo.company
        }
    }
    
    private func validateForm() -> Bool {
        // Check required fields
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter a property title"
            showingValidationAlert = true
            return false
        }
        
        // Validate email if provided
        if !brokerEmail.isEmpty && !isValidEmail(brokerEmail) {
            validationMessage = "Please enter a valid email address"
            showingValidationAlert = true
            return false
        }
        
        // Validate phone if provided
        if !brokerPhone.isEmpty && !isValidPhone(brokerPhone) {
            validationMessage = "Please enter a valid phone number"
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9+\\(\\)\\-\\.\\s]{10,}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
    
    private func saveProperty() {
        guard validateForm() else { return }
        
        // Save broker info to UserDefaults
        let brokerInfo = BrokerInfo(
            name: brokerName,
            phone: brokerPhone,
            email: brokerEmail,
            company: brokerCompany
        )
        
        if brokerInfo.isComplete {
            userDefaultsManager.saveBrokerInfo(brokerInfo)
        }
        
        // Create property object
        let property = Property(
            title: title,
            propertyType: propertyType,
            size: Double(size) ?? 0,
            sizeUnit: sizeUnit,
            price: Double(price) ?? 0,
            priceType: priceType,
            address: address,
            description: propertyDescription,
            brokerInfo: brokerInfo,
            imageData: propertyImage.jpegData(compressionQuality: 0.8)
        )
        
        // Save property to UserDefaults
        userDefaultsManager.saveProperty(property)
        
        // Increment flyer count
        flyersCreated += 1
        
        // Show success feedback
        withAnimation {
            savedSuccessfully = true
        }
        
        // Dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    // MARK: - Keyboard Navigation
    
    private func focusNextField() {
        switch focusedField {
        case .title:
            focusedField = .size
        case .size:
            focusedField = .price
        case .price:
            focusedField = .address
        case .address:
            focusedField = .description
        case .description:
            focusedField = .brokerName
        case .brokerName:
            focusedField = .brokerPhone
        case .brokerPhone:
            focusedField = .brokerEmail
        case .brokerEmail:
            focusedField = .brokerCompany
        case .brokerCompany, .none:
            focusedField = nil
        }
    }
    
    private func focusPreviousField() {
        switch focusedField {
        case .brokerCompany:
            focusedField = .brokerEmail
        case .brokerEmail:
            focusedField = .brokerPhone
        case .brokerPhone:
            focusedField = .brokerName
        case .brokerName:
            focusedField = .description
        case .description:
            focusedField = .address
        case .address:
            focusedField = .price
        case .price:
            focusedField = .size
        case .size:
            focusedField = .title
        case .title, .none:
            focusedField = nil
        }
    }
    
    private func canFocusNextField() -> Bool {
        return focusedField != .brokerCompany && focusedField != nil
    }
    
    private func canFocusPreviousField() -> Bool {
        return focusedField != .title && focusedField != nil
    }
}
