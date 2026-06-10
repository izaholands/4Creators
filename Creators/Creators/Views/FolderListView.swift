//
//  FolderListView.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import SwiftUI
import CoreData



struct FolderListView: View {
    
    
    @Environment(\.managedObjectContext)
    private var context
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Folder.createdAt,
                ascending: false
            )
        ]
        
    )
    private var folders: FetchedResults<Folder>
    
    var body: some View {
        
        List{
            
            
            ForEach(folders){ folder in
                NavigationLink {
                    FolderFormView(folder: folder)
                } label: {
                    
                    Text(folder.name ?? "")
                    
                }
            }
            .onDelete(perform: deleteFolders)
        }
        .navigationTitle("Pastas")
        .toolbar{
            
            NavigationLink {
                FolderFormView(folder: nil)
            } label: {
                Image(systemName: "plus")
            }
            
        }
        
    }
    
    
    private func deleteFolders(
        as offset: IndexSet
    ){
        offset
            .map{folders[$0]}
            .forEach(context.delete)
        
    }
    
}
