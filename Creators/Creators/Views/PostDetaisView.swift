import SwiftUI
import CoreData

struct NavDetailsPublication: View {
    let post: Post

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var exibirTudoRoteiro: Bool = false
    @State private var exibirTudoBriefing: Bool = false

    private let postService = PostService()

    // Variáveis auxiliares de formatação
    private var statusIcone: String { "arrow.up.circle" }
    private var statusCor: Color { post.status == PostStatus.posted.rawValue ? .green : .red }
    private var statusTexto: String { post.status == PostStatus.posted.rawValue ? "Postado" : "Não postado" }

    private var dataHora: String {
        guard let date = post.publishDate else { return "Sem data" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "dd 'de' MMMM, HH:mm"
        return df.string(from: date)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Título ajustado para subir um pouco
                    Text(post.title ?? "Sem título")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, -10)

                    // Grupo de Status, Data, Plataforma com alinhamento fixo
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            Image(systemName: statusIcone).foregroundColor(statusCor).frame(width: 20)
                            Text(statusTexto)
                        }
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock").foregroundColor(.indigo).frame(width: 20)
                            Text(dataHora).font(.system(size: 15))
                        }
                        HStack(spacing: 12) {
                            Image(systemName: "video.fill").foregroundColor(.indigo).frame(width: 20)
                            Text(post.plataform ?? "").font(.system(size: 16, weight: .bold))
                        }
                    }

                    // Pasta (se existir)
                    if let folder = post.folder {
                        HStack {
                            Text("Pasta")
                            Spacer()
                            HStack(spacing: 8) {
                                Text(folder.name ?? "")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.gray)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }

                    // Roteiro
                    if let script = post.script, !script.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Roteiro").font(.system(size: 20, weight: .semibold))
                            Text(script).lineLimit(exibirTudoRoteiro ? nil : 4)
                            Button(exibirTudoRoteiro ? "Ver menos" : "Ver mais") { withAnimation { exibirTudoRoteiro.toggle() } }
                                .foregroundColor(.indigo)
                        }
                    }

                    // Briefing
                    if let briefing = post.briefing, !briefing.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Briefing").font(.system(size: 20, weight: .semibold))
                            Text(briefing).lineLimit(exibirTudoBriefing ? nil : 4)
                            Button(exibirTudoBriefing ? "Ver menos" : "Ver mais") { withAnimation { exibirTudoBriefing.toggle() } }
                                .foregroundColor(.indigo)
                        }
                    }
                    
                    // Espaçamento para o conteúdo não ficar atrás do botão
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

            // Botão fixo na base
            if post.status != PostStatus.posted.rawValue {
                Button { marcarComoPostado() } label: {
                    Text("Postado")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.indigo)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
                .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination:
                    NewPostView(selectedTab: .constant(1), postToEdit: post)
                        .environment(\.managedObjectContext, context)
                ) {
                    Image(systemName: "pencil")
                }
            }
        }
    }

    private func marcarComoPostado() {
        postService.updatePost(
            post,
            title: post.title ?? "",
            script: post.script ?? "",
            plataform: Plataform(rawValue: post.plataform ?? "") ?? .instagram,
            status: .posted,
            publishDate: post.publishDate,
            briefing: post.briefing,
            folder: post.folder
        )
        do {
            try postService.save(context: context)
            dismiss()
        } catch {
            print("Erro ao atualizar status: \(error)")
        }
    }
}
