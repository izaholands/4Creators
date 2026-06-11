//
//  PostService.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import CoreData

protocol PostServiceProtocol {

    func createPost(
        title: String,
        script: String,
        plataform: Plataform,
        status: PostStatus,
        publishDate: Date?,
        briefing: String?,
        folder: Folder?,
        context: NSManagedObjectContext
    )

    func deletePost(
        _ post: Post,
        context: NSManagedObjectContext
    )
    
    func updatePost(
            _ post: Post,
            title: String,
            script: String,
            plataform: Plataform,
            status: PostStatus,
            publishDate: Date?,
            briefing: String?,
            folder: Folder?
        )

    func save(
        context: NSManagedObjectContext
    ) throws
}


final class PostService: PostServiceProtocol {

    func createPost(
        title: String,
        script: String,
        plataform: Plataform,
        status: PostStatus,
        publishDate: Date?,
        briefing: String?,
        folder: Folder?,
        context: NSManagedObjectContext
    ) {

        let post = Post( context: context)

        post.id = UUID()
        post.title = title
        post.script = script
        post.plataform = plataform.rawValue
        post.status = status.rawValue
        post.publishDate = publishDate
        post.briefing = briefing
        post.folder = folder
        post.createdAt = Date()
    }
    
    func updatePost(
            _ post: Post,
            title: String,
            script: String,
            plataform: Plataform,
            status: PostStatus,
            publishDate: Date?,
            briefing: String?,
            folder: Folder?
        ) {
            post.title = title
            post.script = script
            post.plataform = plataform.rawValue
            post.status = status.rawValue
            post.publishDate = publishDate
            post.briefing = briefing
            post.folder = folder
        }

    func deletePost(_ post: Post, context: NSManagedObjectContext) {
        context.delete(post)
    }

    func save(context: NSManagedObjectContext) throws {
        try context.save()
    }
}
