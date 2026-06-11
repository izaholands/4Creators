//
//  CreatorsApp.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI

@main
struct CreatorsApp: App {
  
    let persistenceController = PersistenceController.shared
    
    init() {
              UINavigationBar.appearance().tintColor = .systemIndigo
          }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}
