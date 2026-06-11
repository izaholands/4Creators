//
//  NavPastaOpen..swift
//  Creators
//
//  Created by Academy on 10/06/26.
//

import SwiftUI

//tela de detalhes quando clica na pasta
struct NavPastaOpen_: View {
    var body: some View {
      
            VStack{
                ScrollView{
                    VStack(spacing: 20) {
                        Color.clear
                            .frame(height: 10)
                        ForEach(SearchProviderGRWM.all()){ pastaGRWM in
                                CardsPastasGRWM(pastaGRWM: pastaGRWM)
                            
                        }
                    }
                }
            }
            //.navigationTitle("GRWM")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                //titulo e icoone
                ToolbarItem(placement: .principal){
                    HStack(spacing: 4){
                        Text("GRWM")
                            
                            .font(.system(size: 17, weight: .semibold))
                        
                      
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        print("acao")
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.indigo)
                    }
                        
                    
                }
            })

            
        
        
    }
}

struct NavPastaOpen__Previews: PreviewProvider {
    static var previews: some View {
        NavPastaOpen_()
    }
}
