//
//  FolderService.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import CoreData

import CoreData

protocol FolderServiceProtocol {

    func createFolder(name: String, context: NSManagedObjectContext)

    func renameFolder(_ folder: Folder,name: String)

    func deleteFolder(_ folder: Folder,context: NSManagedObjectContext)

    func save(context: NSManagedObjectContext) throws
}


final class FolderService: FolderServiceProtocol {

    func createFolder(name: String,context: NSManagedObjectContext) {

        let folder = Folder(context: context)
        folder.id = UUID()
        folder.name = name
        folder.createdAt = Date()
    }

    func renameFolder(_ folder: Folder,name: String) {
        folder.name = name
    }

    func deleteFolder(_ folder: Folder,context: NSManagedObjectContext) {
        context.delete(folder)
    }

    func save(context: NSManagedObjectContext) throws {
        try context.save()
    }
}
