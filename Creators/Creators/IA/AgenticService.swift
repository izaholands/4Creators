//
//  AgenticService.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import CoreData

final class AgentService {

    private let postService = PostService()

    private let folderService = FolderService()

    func execute(action: AgentAction,context: NSManagedObjectContext) {

        switch action {

        
        case .createFolder(let name):

            folderService.createFolder(name: name,context: context)

            try? folderService.save(context: context)

        case .createPost(let title,let plataform):

            postService.createPost(
                title: title,
                plataform: plataform,
                status: .not_posted,
                publishDate: nil,
                briefing: nil,
                folder: nil,
                context: context
            )

            try? postService.save(context: context)

        case .movePost:

            print("TODO")

        case .unknown:

            print("Ação desconhecida")
        }
    }
}
