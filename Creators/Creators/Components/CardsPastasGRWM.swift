//
//  CardsPastasGRWM.swift
//  Creators
//
//  Created by Academy on 10/06/26.
//

import SwiftUI

struct CardsPastasGRWM: View {
    let pastaGRWM: PastaGRWM
    
    var body: some View {
        
       
        VStack(alignment: .leading, spacing: 24) {

            Text(pastaGRWM.titulo)
                .font(.system(size: 20, weight: .bold))
            VStack(alignment: .leading, spacing: 16) {
                    
                    ForEach(pastaGRWM.status.indices, id: \.self) { index in
                        let item = pastaGRWM.status[index]

                        HStack(spacing: 16) {
                            Image(systemName: item.icone)
                                .font(.system(size: 25))
                                .foregroundColor(item.cor)

                            Text(item.texto)
                        }
                    }
                
            }

            HStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 25))
                    .foregroundColor(.indigo)

                Text("\(pastaGRWM.data), \(pastaGRWM.hora)")
                    .font(.system(size: 15))
            }

            HStack(spacing: 16) {
                //play.square.stack.fill
                //MUDAR AQUI O ICONEEEEEEEEEEEEEEEEEE
                Image(systemName: "video.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.indigo)

                Text(pastaGRWM.plataforma)
                    .font(.system(size: 15, weight: .bold))
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

struct CardsPastasGRWM_Previews: PreviewProvider {
    static var previews: some View {
        CardsPastasGRWM(pastaGRWM: SearchProviderGRWM.all()[0])
    }
}
