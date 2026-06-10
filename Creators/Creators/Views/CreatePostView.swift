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
    
    @StateObject
    private var viewModel = PostFormViewModel()
    
    
    var body: some View {
        
        Form{
            
            Section("Informacoes") {
                TextField("Titulo", text: $viewModel.title)
                
                Picker("Plataforma", selection: $viewModel.selectedPlataform) {
                    ForEach(Plataform.allCases, id: \.self){ plataform in
                        Text(plataform.rawValue)
                    }
                    
                }
                
                Picker("Status", selection: $viewModel.selectedStatus) {
                    ForEach(PostStatus.allCases, id: \.self){ status in
                        Text(status.rawValue.capitalized)
                            .tag(status)
                    }
                }
                
                Picker("Pasta", selection: $viewModel.selectedFolder){
                    Text("Nenhuma")
                        .tag(nil as Folder?)
                    
                    ForEach(folders){folder in
                        Text(folder.name ?? "")
                            .tag(folder as Folder?)
                    }
                }
                
                DatePicker("Publicação", selection: $viewModel.publishDate, displayedComponents: .date)
                
            }
            
            Section("Observações"){
                
                TextEditor(text: $viewModel.briefing)
                    .frame(height: 100)
                
            }
            
            Button("Salvar"){
                
                if let post {
                    viewModel.save(context: context, post: post)
                }
                
                presentationMode
                    .wrappedValue
                    .dismiss()
            }
        }
        .navigationTitle(post == nil ? "Novo post" : "Editar post")
        .onAppear{
            if let post{
                viewModel.load(post: post)
            }
        }
        
    }
}


private extension PostFormView {
    
    func loadPost(){
        
        guard let post else {
            return
        }
        
        viewModel.title = post.title ?? ""
        
        viewModel.selectedPlataform = Plataform(rawValue: post.plataform ?? "") ?? .instagram
        viewModel.selectedStatus = PostStatus(rawValue: post.status ?? "") ?? .not_posted
        viewModel.publishDate = post.publishDate ?? Date()
        viewModel.briefing = post.briefing ?? ""
        viewModel.selectedFolder = post.folder
        
        
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
        
        currentPost.title = viewModel.title
        currentPost.plataform = viewModel.selectedPlataform.rawValue
        currentPost.status = viewModel.selectedStatus.rawValue
        currentPost.publishDate = viewModel.publishDate
        currentPost.briefing = viewModel.briefing
        currentPost.folder = viewModel.selectedFolder
        
        do {
            
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
