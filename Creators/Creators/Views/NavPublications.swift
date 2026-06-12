//
//  ContentView.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import SwiftUI

struct NavPublications: View {
    
    enum TipoConteudo: String, CaseIterable {
        case publicacoes = "Publicações"
        case pastas = "Pastas"
    }
    @State private var padrao: TipoConteudo = .publicacoes
    
    @State private var searchText = ""

    private var searchResult: [SearchDetails] {
        if searchText.isEmpty {
            return SearchProvider.all()
        }

        return SearchProvider.all().filter {
            $0.titulo.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var searchResultPastas: [SearchPastas]{
        if searchText.isEmpty{
            return SearchProviderPastas.all()
        }
        return SearchProviderPastas.all().filter{
            $0.nomepasta
                .localizedCaseInsensitiveContains(searchText)
        }
        
    }
    
    @Environment(\.managedObjectContext)
    private var context
    
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Post.createdAt,
                ascending: false
            )
        ]
    )
    private var posts: FetchedResults<Post>

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Folder.createdAt,
                ascending: false
            )
        ]
    )
    private var folders: FetchedResults<Folder>
    
    init() {
        UIScrollView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        NavigationView{
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Pesquisar...", text: $searchText)
                
                Image(systemName: "mic.fill")
            }
            .padding()
            .background(Color("cintaCustom"))
            .cornerRadius(100)
            .padding()

            
            HStack{
                Picker("", selection: $padrao ) {
                    ForEach(TipoConteudo.allCases, id: \.self) { tipo in
                        Text(tipo.rawValue)
                            
                    }
                    .padding(2)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .bottom])
                .cornerRadius(9)
            }
            
            ScrollView{
                VStack(spacing: 12) {
                    switch padrao {
                    
                    case .publicacoes:
                        if posts.isEmpty {
                            
                            // mock preview
                            ForEach(SearchProvider.all()){ post in
                                Cards(post: post)
                                    .padding(.bottom, 10)
                            }
                            
//                            Text("Nenhuma publicação encontrada")
//                                .foregroundColor(.secondary)
//                                .padding(.top, 40)
                        } else {
                            ForEach(posts.filter {
                                searchText.isEmpty ||
                                ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
                            }) { post in
                                Cards(post: post)
                            }
                        }
                    //exibe a tela de pastas
                    case .pastas:
                        if folders.isEmpty {
                            Text("Nenhuma pasta encontrada")
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            
                            ForEach(folders.filter {
                                searchText.isEmpty ||
                                ($0.name ?? "").localizedCaseInsensitiveContains(searchText)
                            }) { folder in
                                CardsPastas(folder: folder)
                            }
                        }
                    }
                }
                .background(Color.white)
                .frame(maxWidth: .infinity)
            }
            .background(Color.white)
            .padding(.bottom, 50)
        
        }
        .navigationBarHidden(true)
        .navigationTitle("Voltar")
        
        }
        .tint(.indigo)
    }
}

//struct NavPublications_Previews: PreviewProvider {
//    static var previews: some View {
//        NavPublications()
//        
//    }
//}
//
#Preview {
    NavPublications()
}
