//
//  FolderFormView.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import SwiftUI
import CoreData


struct FolderFormView: View {
    
    
    @Environment(\.managedObjectContext)
    private var context
    
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let folder: Folder?
    
    @State private var name = ""
    
    var body: some View {
        
        Form{
            
            TextField("Nome da pasta", text: $name)
            
            
            Button("salvar"){
                saveFolder()
            }
            
        }
        .navigationTitle(folder == nil ? "Noma pasta" : "Editar pasta")
        .onAppear{
            
            if let folder {
                name = folder.name ?? ""
            }
            
        }
        
    }
    
    private func saveFolder(){
        
        let currentFolder: Folder
        
        if let folder {
            
            currentFolder = folder
            
        } else {
            
            currentFolder = Folder(
                context: context
            )
            
            currentFolder.id = UUID()
            currentFolder.createdAt = Date()
        }
        
        currentFolder.name = name
        
        try? context.save()
        
        presentationMode
            .wrappedValue
            .dismiss()
    }
    
}
