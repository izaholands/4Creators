import SwiftUI

struct NavPastaOpen: View {
    
    let folder: Folder
    
    @Binding var navigationDepth: Int
    
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
                        
                        NavigationLink {
                            
                            NavDetailsPublication(post: post)
                                .onAppear {
                                    navigationDepth += 1
                                }
                                .onDisappear {
                                    navigationDepth -= 1
                                }
                            
                        } label: {
                            
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
