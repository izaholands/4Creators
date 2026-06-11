//
//  Cards.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI

struct Cards: View {
    let title: String
    let textStatus: String
    let iconStatus: String
    let colorStatus: Color
    let date: String
    let time: String
    let plataform: String
    
    init(post: Post){
        
        self.title = post.title ?? "Sem titulo"
        self.plataform = post.plataform ?? "Instagram"
        
        switch PostStatus(rawValue: post.status ?? "") {
            
        case .not_posted:
            self.textStatus = "Não postado"
            self.iconStatus = "arrow.down.circle"
            self.colorStatus = .red
            
        case .posted:
            self.textStatus = "Postado"
            self.iconStatus = "arrow.up.circle"
            self.colorStatus = .green
            
        case .none:
            self.textStatus = "Rascunho"
            self.iconStatus = "pencil"
            self.colorStatus = .gray
        }
        
        if let date = post.publishDate {
            let df = DateFormatter()
            df.locale = Locale(identifier: "pt_BR")
            df.dateFormat = "dd/MM/yyyy"
            self.date = df.string(from: date)
            df.dateFormat = "HH:mm"
            self.time = df.string(from: date)
        } else {
            self.date = "Sem data"
            self.time = ""
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text(title)
                .font(.system(size: 20, weight: .bold))

            HStack(spacing: 16) {
                Image(systemName: iconStatus)
                    .font(.system(size: 25))
                    .foregroundColor(colorStatus)
                Text(textStatus)
                    .font(.system(size: 16, weight: .bold))
            }

            HStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 25))
                    .foregroundColor(.indigo)

                Text(time.isEmpty ? date : "\(date), \(time)")
                    .font(.system(size: 15))
            }

            HStack(spacing: 16) {
                //play.square.stack.fill
                //MUDAR AQUI O ICONEEEEEEEEEEEEEEEEEE
                Image(systemName: "play.square.stack.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.indigo)

                Text(plataform)
                    .font(.system(size: 15))
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color("CardColor"))
        .background(.white)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.12),radius: 25,x: 0,y: 15)
        .padding(.horizontal)
    }
}

//struct Cards_Previews: PreviewProvider {
//    static var previews: some View {
//        Cards(post: SearchProvider.all()[0])
//    }
//}
