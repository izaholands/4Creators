import SwiftUI

struct NavDetailsPublication: View {
    let post: Post
    

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var exibirTudoRoteiro: Bool = false
    @State private var exibirTudoBriefing: Bool = false

    private let postService = PostService()

    private var statusIcone: String {
        post.status == PostStatus.posted.rawValue ? "arrow.up.circle" : "arrow.up.circle"
    }

    private var statusCor: Color {
        post.status == PostStatus.posted.rawValue ? .green : .red
    }

    private var statusTexto: String {
        post.status == PostStatus.posted.rawValue ? "Postado" : "Não postado"
    }

    private var dataHora: String {
        guard let date = post.publishDate else { return "Sem data" }
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "dd 'de' MMMM, HH:mm"
        return df.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Título
                    Text(post.title ?? "Sem título")
                        .font(.system(size: 28, weight: .bold))

                    // Status
                    HStack {
                        Image(systemName: statusIcone)
                            .font(.system(size: 20))
                            .foregroundColor(statusCor)
                        Text(statusTexto)
                    }

                    // Data
                    HStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 20))
                            .foregroundColor(.indigo)
                        Text(dataHora)
                            .font(.system(size: 15))
                    }

                    // Plataforma
                    HStack(spacing: 16) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.indigo)
                        Text(post.plataform ?? "")
                            .font(.system(size: 16, weight: .bold))
                    }

                    // Pasta
                    if let folder = post.folder {
                        HStack {
                            Text("Pasta")
                            Spacer()
                            HStack(spacing: 8) {
                                Text(folder.name ?? "")
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // Roteiro
                    if let script = post.script, !script.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Roteiro")
                                .font(.system(size: 20, weight: .semibold))
                            Text(script)
                                .lineLimit(exibirTudoRoteiro ? nil : 4)
                            Button(exibirTudoRoteiro ? "Ver menos" : "Ver mais") {
                                withAnimation { exibirTudoRoteiro.toggle() }
                            }
                            .foregroundColor(.indigo)
                        }
                    }

                    // Briefing
                    if let briefing = post.briefing, !briefing.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Briefing")
                                .font(.system(size: 20, weight: .semibold))
                            Text(briefing)
                                .lineLimit(exibirTudoBriefing ? nil : 4)
                            Button(exibirTudoBriefing ? "Ver menos" : "Ver mais") {
                                withAnimation { exibirTudoBriefing.toggle() }
                            }
                            .foregroundColor(.indigo)
                        }
                    }

                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) {
                // Botão postado — só aparece se ainda não postado
                if post.status != PostStatus.posted.rawValue {
                    Button {
                        marcarComoPostado()
                    } label: {
                        Text("Vídeo postado")
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .padding(.bottom, 83)
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

    // MARK: - Actions

    private func marcarComoPostado() {
        postService.updatePost(
            post,
            title: post.title ?? "",
            script: post.script ?? "",
            plataform: Plataform(rawValue: post.plataform ?? "") ?? .tiktok,
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
