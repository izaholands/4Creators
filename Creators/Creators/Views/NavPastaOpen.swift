import SwiftUI

struct NavPastaOpen: View {
    
    let folder: Folder
    
    @State private var mostrarSheet = false

    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Post.createdAt,
                ascending: false
            )
        ]
    )
    private var posts: FetchedResults<Post>
    
    
    private var postsDaPasta: [Post] {
        
        posts.filter {
            
            $0.folder?.objectID == folder.objectID
            
        }
    }
    
    var body: some View {
        
        ScrollView {
            
            if postsDaPasta.isEmpty {
                
                VStack {
                    
                    Spacer()
                    
                    Text("Nenhuma publicação nesta pasta")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
            } else {
                
                VStack(spacing: 12) {
                    
                    ForEach(postsDaPasta) { post in
                        
                        NavigationLink(destination: NavDetailsPublication(post: post)
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        ) {
                            Cards(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
//        .navigationTitle(folder.name ?? "Pasta")
        //.navigationTitle("Voltar")
        .navigationBarTitleDisplayMode(.inline)

        
        .toolbar(content: {
                       //titulo e icoone
                       ToolbarItem(placement: .principal){
                           HStack(spacing: 4){
                               Text(folder.name ?? "Pasta")
                                   
                                   .font(.system(size: 17, weight: .semibold))
                               
                             
                           }
                           
                       }
                       ToolbarItem(placement: .navigationBarTrailing){
                           Button(action: {
                               mostrarSheet.toggle()
                           }) {
                               Image(systemName: "plus")
                                   .foregroundColor(.indigo)
                           }
                       }
        }).sheet(isPresented: $mostrarSheet){
            AddPublicacoes(folder: folder)
        }


    }
}

struct AddPublicacoes: View{
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context


    
    let folder: Folder
    @State private var searchText = ""

    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Post.createdAt,
                ascending: false
            )
        ]
    )
    private var posts: FetchedResults<Post>
    
  

        var searchResult: [Post] {
            if searchText.isEmpty {
                return Array(posts)
            }

            return posts.filter {
                ($0.title ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }

    var body: some View{
        VStack {
            HStack {
                ZStack {
                    Text("Adicionar Postagem")
                        .font(.system(size: 20, weight: .semibold))

                    HStack {
                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Pesquisar...", text: $searchText)
                
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
            
            ScrollView{
                VStack{
                    ForEach(searchResult.filter { $0.folder?.objectID != folder.objectID })
                    { post in
                            Button {
                                post.folder = folder
                                
                                do{
                                    try context.save()
                                }catch{
                                    print(error.localizedDescription)
                                }

                                dismiss()
                            } label: {
                                Cards(post: post)
                            }
                            .buttonStyle(.plain)
                    }
                }
            }
            
            
                
            
            
        }.interactiveDismissDisabled()
    }

    
}



//struct NavPastaOpen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavPastaOpen(folder: <#Folder#>)
//
//    }
//}
struct NavPastaOpen_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = PersistenceController.shared.container.viewContext
        
        let folder = Folder(context: context)
        folder.name = "GRWM"
        
        return NavigationView {
            NavPastaOpen(folder: folder)
                .environment(\.managedObjectContext, context)
        }
    }
}
