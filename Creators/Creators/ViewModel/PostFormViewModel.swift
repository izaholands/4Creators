//
//  PostFormViewModel.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import CoreData


final class PostFormViewModel: ObservableObject {
    
    @Published var title = ""
    @Published var selectedPlataform = Plataform.instagram
    @Published var selectedStatus = PostStatus.not_posted
    @Published var publishDate = Date()
    @Published var briefing = ""
    @Published var selectedFolder: Folder?
    @Published var script = ""
    
    private var service: PostServiceProtocol
    
    init(service: PostServiceProtocol = PostService()){
        self.service = service
    }
    
    func load(post: Post){
        
        title = post.title ?? ""
        script = post.script ?? ""
        selectedPlataform = Plataform(rawValue: post.plataform ?? "") ?? .instagram
        selectedStatus = PostStatus(rawValue: post.status ?? "") ?? .not_posted
        publishDate = post.publishDate ?? Date()
        briefing = post.briefing ?? ""
        selectedFolder = post.folder
        
    }
    
    func save(context: NSManagedObjectContext, post: Post?) {

        let currentPost: Post
        if let post {
            currentPost = post
        } else {
            currentPost = Post(context: context)
            currentPost.id = UUID()
            currentPost.createdAt = Date()
        }
        currentPost.title = title
        currentPost.script = script
        currentPost.plataform = selectedPlataform.rawValue
        currentPost.status = selectedStatus.rawValue
        currentPost.publishDate = publishDate
        currentPost.briefing = briefing
        currentPost.folder = selectedFolder
        
        try? context.save()
    }
    
    func createPost(context: NSManagedObjectContext) {

        service.createPost(
            title: title,
            script: script,
            plataform: selectedPlataform,
            status: selectedStatus,
            publishDate: publishDate,
            briefing: briefing,
            folder: selectedFolder,
            context: context
        )

        try? service.save(context: context)
    }
    
}
