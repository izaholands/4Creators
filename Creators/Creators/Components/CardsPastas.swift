//  SwiftUIView.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI

struct CardsPastas: View {
    
    let folderName: String
    let totalPosts: Int
    
    init(folder: Folder){
        self.folderName = folder.name ?? "Sem nome"
        self.totalPosts = (folder.posts as? Set<Post>)?.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text(folderName)
                .font(.system(size: 20, weight: .bold))

            
            HStack(spacing: 16) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.indigo)
                Text("\(totalPosts) post\(totalPosts == 1 ? "" : "s")")
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(40)
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 25,
            x: 0,
            y: 15
        )
        .padding(.horizontal)
    }
}

//struct CardsPastas_Previews: PreviewProvider {
//    static var previews: some View {
//        CardsPastas(pastas: SearchProviderPastas.all()[0])
//    }
//}
