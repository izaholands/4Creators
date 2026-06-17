import SwiftUI

struct NavPastaOpen: View {
    
    let folder: Folder
    
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
        .navigationTitle(folder.name ?? "Pasta")
    }
}
