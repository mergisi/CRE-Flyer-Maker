//
//  CameraView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraPicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var navigateToFlyerDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(AppColors.lightGray)
                    .ignoresSafeArea()
                
                if let selectedImage = selectedImage {
                    // Image preview
                    VStack(spacing: 0) {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                            .background(Color.black)
                            .cornerRadius(12)
                            .padding()
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                navigateToFlyerDetail = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text("Create Flyer")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryBlue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                self.selectedImage = nil
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Retake Photo")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primaryBlue, lineWidth: 2)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                } else {
                    // Camera selection options
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primaryBlue)
                            
                            Text("Add Property Photo")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.darkGray)
                            
                            Text("Take a photo or select from your gallery")
                                .font(.body)
                                .foregroundColor(AppColors.mediumGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                checkCameraPermissionAndOpen()
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Take Photo")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryBlue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                checkPhotoLibraryPermissionAndOpen()
                            }) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Choose from Gallery")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(AppColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primaryBlue, lineWidth: 2)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .navigationDestination(isPresented: $navigateToFlyerDetail) {
                if let image = selectedImage {
                    PropertyFormView(propertyImage: image)
                }
            }
        }
        .sheet(isPresented: $showingCameraPicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(permissionAlertMessage)
        }
    }
    
    private func checkCameraPermissionAndOpen() {
        // First check if camera is available on device
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            permissionAlertMessage = "Camera is not available on this device."
            showingPermissionAlert = true
            return
        }
        
        // Check camera authorization status
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Permission already granted
            DispatchQueue.main.async {
                self.showingCameraPicker = true
            }
            
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingCameraPicker = true
                    } else {
                        self.permissionAlertMessage = "Camera access is required to take photos. Please enable camera access in Settings."
                        self.showingPermissionAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied
            permissionAlertMessage = "Camera access is denied. Please enable camera access in Settings to take photos."
            showingPermissionAlert = true
            
        @unknown default:
            permissionAlertMessage = "Unable to access camera. Please try again."
            showingPermissionAlert = true
        }
    }
    
    private func checkPhotoLibraryPermissionAndOpen() {
        // Photo library access is handled by the system picker automatically
        showingImagePicker = true
    }
}