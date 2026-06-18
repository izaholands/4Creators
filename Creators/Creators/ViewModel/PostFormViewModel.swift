import Foundation
import CoreData
import UserNotifications

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
        let postID: UUID
        
        if let post = post {
            currentPost = post
            postID = post.id ?? UUID()
            NotificationManager.cancel(identifier: postID)
        } else {
            currentPost = Post(context: context)
            postID = UUID()
            currentPost.id = postID
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
        print("salvando o post")
        
        print("publish date: \(publishDate)")
        if publishDate > Date() {
            print("entrei no if")
            NotificationManager.schedule(title: title, date: publishDate, identifier: postID)
            // Chamada de verificação
            NotificationManager.verificarAgendadas()
        }
    }
    
    func createPost(context: NSManagedObjectContext) {
        let newPostID = UUID()

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
        print("to aqui no create post")
        if publishDate > Date() {
            NotificationManager.schedule(title: title, date: publishDate, identifier: newPostID)
            
            NotificationManager.verificarAgendadas()
        }
    }
}
