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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
