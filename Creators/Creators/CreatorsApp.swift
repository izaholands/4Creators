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
  
    var body: some Scene {
        WindowGroup {
//            PostListView()
//                .environment(
//                    \.managedObjectContext,
//                     persistenceController
//                        .container
//                        .viewContext
//                )
            ContentView()
        }
    }
}
