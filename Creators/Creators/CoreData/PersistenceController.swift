//
//  PersistenceController.swift
//  Creators
//
//  Created by admin on 09/06/26.
//

import Foundation
import CoreData


struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(){
        
        container = NSPersistentContainer(
            name: "FourCreators"
        )
        
      container.loadPersistentStores { _, error in
          
        if let error = error {
          
          fatalError("error ao carregar core data: \(error)")
          
        }
          
      }
        
    }
    
}
