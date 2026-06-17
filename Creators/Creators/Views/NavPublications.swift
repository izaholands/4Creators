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
//    
    var body: some View {
        NavigationView{
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 16)

                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Pesquisar...")
                                .foregroundColor(Color(.systemGray2))
                                .font(.body)
                        }

                        SearchTextView(text: $searchText)
                            .frame(height: 24)
                    }
                    .padding(.leading, 8)

                    Spacer(minLength: 8)

                    Button {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    searchText
                                        .trimmingCharacters(in: .whitespacesAndNewlines)
                                        .isEmpty
                                    ? Color(.systemGray4)
                                    : Color.indigo
                                )
                                .frame(width: 32, height: 32)

                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(
                        searchText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                    .padding(.trailing, 8)
                }
                .padding(.vertical, 8)
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
                                Text("Nenhum post encontrado")
                            } else {
                                ForEach(posts.filter {
                                    searchText.isEmpty ||
                                    ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
                                }) { post in
                                    NavigationLink(destination: NavDetailsPublication(post: post)
                                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                    ) {
                                        Cards(post: post)
                                    }
                                    .buttonStyle(.plain)}
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
                                    
                                    // pastas — depois:
                                    NavigationLink {
                                        NavPastaOpen(folder: folder)
                                    } label: {
                                        CardsPastas(folder: folder)
                                    }
                                    .buttonStyle(.plain)
                                    
                                
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }
                .background(Color.white)
                .padding(.bottom, 50)
                
            }
            .navigationBarHidden(true)
            .navigationTitle("Voltar")
            
        }
        .tint(.indigo)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MudarParaAbaPastas"))) {_ in
                withAnimation{
                    self.padrao = .pastas
                }
        }
    }
}

struct SearchTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.delegate = context.coordinator
        
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.maximumNumberOfLines = 1
        tv.textContainer.lineBreakMode = .byTruncatingTail
        tv.returnKeyType = .search
        
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text.replacingOccurrences(of: "\n", with: "")
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
}

//struct NavPublications_Previews: PreviewProvider {
//    static var previews: some View {
//        NavPublications()
//
//    }
//}
//
//#Preview {
//    NavPublications()
//}
