//  SwiftUIView.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI

struct CardsPastas: View {
    
    let folderName: String
    let totalPosted: Int
    let totalNotPosted: Int
    let isEmpty: Bool
    
    init(folder: Folder){
        self.folderName = folder.name ?? "Sem nome"
        let posts = (folder.posts as? Set<Post>) ?? []
        self.totalPosted = posts.filter { $0.status == PostStatus.posted.rawValue }.count
        self.totalNotPosted = posts.filter { $0.status == PostStatus.not_posted.rawValue }.count
        self.isEmpty = posts.isEmpty
        
    }
    
    // Init para mocks
    init(pastas: SearchPastas) {
        self.folderName = pastas.nomepasta
        self.totalPosted = pastas.status.filter { $0.texto == "Postado" }.count
        self.totalNotPosted = pastas.status.filter { $0.texto == "Não postado" }.count
        self.isEmpty = pastas.status.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text(folderName)
                .font(.system(size: 20, weight: .bold))
            
            
            if isEmpty{
                Text("Pasta vázia")
                    .foregroundStyle(.gray)
            } else {
                
                VStack(alignment: .leading, spacing: 12) {
                    if totalPosted > 0 {
                        HStack(spacing: 16) {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            Text("\(totalPosted) item(s) postado\(totalPosted == 1 ? "" : "s")")
                        }
                    }
                    if totalNotPosted > 0 {
                        HStack(spacing: 16) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text("\(totalNotPosted) item(s) não postado\(totalNotPosted == 1 ? "" : "s")")
                        }
                    }
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.12), radius: 25, x: 0, y: 15)
        .padding(.horizontal)
    }
}


//struct CardsPastas_Previews: PreviewProvider {
//    static var previews: some View {
//        CardsPastas(pastas: SearchProviderGRWM.all()[0])
//    }
//}
