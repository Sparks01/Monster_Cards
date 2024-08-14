//
//  Monster_CardsApp.swift
//  Monster Cards
//
//  Created by JXMUNOZ on 1/18/24.
//

import SwiftUI

@main
struct Monster_CardsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
