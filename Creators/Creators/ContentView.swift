//
//  ContentView.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext)
    private var context
    
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Post.createdAt,
                ascending: false
            )
        ]
    
    )
    private var posts: FetchedResults<Post>
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(posts){ post in
                    
                    VStack (alignment: .leading){
                        
                        Text(post.title ?? "")
                            .font(.headline)
                        
                        Text(post.plataform ?? "")
                            .font(.caption)
                        
                    }
                
                }
                .onDelete(perform: deletePost)
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink{
                        
                        PostFormView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        
    }
    
    private func createPost(){
        let post = Post(context: context)
        
        post.id = UUID()
        post.title = "Post \(posts.count + 1)"
        post.plataform = Plataform.instagram.rawValue
        post.status = PostStatus.not_posted.rawValue
        post.createdAt = Date()
        
        do {
            
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func deletePost(
        at offsets: IndexSet
    ){
        
        offsets.map {
            posts[$0]
        }
        .forEach(context.delete)
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//
//#Preview {
//    ContentView()
//}
