//
//  CRE_Flyer_MakerApp.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

@main
struct CRE_Flyer_MakerApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                OnboardingView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}