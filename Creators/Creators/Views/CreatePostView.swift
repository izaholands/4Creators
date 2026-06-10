//
//  CreatePostView.swift
//  Creators
//
//  Created by admin on 09/06/26.
//

import SwiftUI
import CoreData

struct PostFormView: View {
    
    @Environment(\.managedObjectContext)
    private var context
    
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    var post: Post?
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Folder.name,
                ascending: true
            )
        ]
    )
    private var folders: FetchedResults<Folder>
    
    @State private var selectedFolder: Folder?
    @State private var title: String = ""
    @State private var selectedPlataform = Plataform.instagram
    @State private var selectedStatus: PostStatus = .not_posted
    @State private var publishDate = Date()
    @State private var briefing: String = ""
    
    
    var body: some View {
        
        Form{
            
            Section("Informacoes") {
                TextField("Titulo", text: $title)
                
                Picker("Plataforma", selection: $selectedPlataform) {
                    ForEach(Plataform.allCases, id: \.self){ plataform in
                        Text(plataform.rawValue)
                    }
                    
                }
                
                Picker("Status", selection: $selectedStatus) {
                    ForEach(PostStatus.allCases, id: \.self){ status in
                        Text(status.rawValue.capitalized)
                            .tag(status)
                    }
                }
                
                Picker("Pasta", selection: $selectedFolder){
                    Text("Nenhuma")
                        .tag(nil as Folder?)
                    
                    ForEach(folders){folder in
                        Text(folder.name ?? "")
                            .tag(folder as Folder?)
                    }
                }
                
                DatePicker("Publicação", selection: $publishDate, displayedComponents: .date)
                
            }
            
            Section("Observações"){
                
                TextEditor(text: $briefing)
                    .frame(height: 100)
                
            }
            
            Button("Salvar"){
                
                savePost()
            }
        }
        .navigationTitle(post == nil ? "Novo post" : "Editar post")
        .onAppear{loadPost()}
        
    }
}


private extension PostFormView {
    
    func loadPost(){
        
        guard let post else {
            return
        }
        
        title = post.title ?? ""
        
        selectedPlataform = Plataform(rawValue: post.plataform ?? "") ?? .instagram
        selectedStatus = PostStatus(rawValue: post.status ?? "") ?? .not_posted
        publishDate = post.publishDate ?? Date()
        briefing = post.briefing ?? ""
        selectedFolder = post.folder
        
        
    }
    
    func savePost(){
        
        let currentPost: Post
        
        if let post{
            currentPost = Post(context: context)
            
        } else {
            currentPost = Post (
                context: context
            )
            currentPost.id = UUID()
            currentPost.createdAt = Date()
            
        }
        
        currentPost.title = title
        currentPost.plataform = selectedPlataform.rawValue
        currentPost.status = selectedStatus.rawValue
        currentPost.publishDate = publishDate
        currentPost.briefing = briefing
        currentPost.folder = selectedFolder
        
        do {
            
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
