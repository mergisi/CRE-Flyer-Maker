//
//  ContentView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// New main content view with NavigationStack and floating action button
struct MainContentView: View {
    @State private var showingCameraView = false
    @State private var properties: [Property] = []
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.lightGray
                    .ignoresSafeArea()
                
                // Main Content
                ScrollView {
                    if properties.isEmpty {
                        VStack(spacing: 20) {
                            Spacer(minLength: 100)
                            
                            Image(systemName: "doc.text.image")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primaryBlue.opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text("No Flyers Yet")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Text("Tap the + button to create your first property flyer")
                                    .font(.body)
                                    .foregroundColor(AppColors.mediumGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            Spacer(minLength: 200)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(properties) { property in
                                PropertyCardView(property: property)
                            }
                        }
                        .padding()
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCameraView = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primaryBlue)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("CRE Flyer Maker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCameraView) {
                CameraView()
            }
            .onAppear {
                loadProperties()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                loadProperties()
            }
        }
    }
    
    private func loadProperties() {
        properties = userDefaultsManager.loadProperties()
    }
}

// Flyer item model
struct FlyerItem: Identifiable {
    let id = UUID()
    let propertyImage: UIImage
    let propertyAddress: String
    let propertyPrice: String
    let propertyType: String
    let createdDate: Date
}

// Property card view
struct PropertyCardView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property Image
            if let imageData = property.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.lightGray)
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "building.2")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.mediumGray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.darkGray)
                    .lineLimit(2)
                
                Text(property.formattedPrice)
                    .font(.caption2)
                    .foregroundColor(AppColors.primaryBlue)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Text(property.propertyType.displayName)
                    Text("•")
                    Text(property.formattedSize)
                }
                .font(.caption2)
                .foregroundColor(AppColors.mediumGray)
                
                if !property.address.isEmpty {
                    Text(property.address)
                        .font(.caption2)
                        .foregroundColor(AppColors.mediumGray)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Main View") {
    MainContentView()
}