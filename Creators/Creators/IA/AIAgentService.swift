//
//  OpenAIService.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation
import CoreData

final class AIAgentService {

    private let aiService: AIService
    private let postService: PostServiceProtocol
    private let folderService: FolderServiceProtocol
    private let context: NSManagedObjectContext

    init(
        aiService: AIService = AIService(),
        postService: PostServiceProtocol,
        folderService: FolderServiceProtocol,
        context: NSManagedObjectContext
    ) {
        self.aiService = aiService
        self.postService = postService
        self.folderService = folderService
        self.context = context
    }

    func handle(userMessage: String) async throws -> String {
        print("userMessage: \(userMessage)")
        let summary = buildContextSummary()
        print("summary: \(summary)")
        let action = try await aiService.interpret(userMessage: userMessage, contextSumary: summary)
        print("action: \(action)")
        return try await execute(action: action)
    }

    
    private func buildContextSummary() -> String {
        let postRequest = Post.fetchRequest()
        let posts = (try? context.fetch(postRequest)) ?? []

        let folderRequest = Folder.fetchRequest()
        let folders = (try? context.fetch(folderRequest)) ?? []

        if posts.isEmpty && folders.isEmpty {
            return "O usuário ainda não tem nenhum post ou pasta cadastrados."
        }

        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.dateFormat = "dd/MM/yyyy HH:mm"

        let now = Date()

        var lines: [String] = []

        // Data/hora atual — essencial pra IA saber o que é "próximo" ou "atrasado"
        lines.append("DATA E HORA ATUAL: \(df.string(from: now))")
        lines.append("")

        // Pastas
        lines.append("Pastas existentes: \(folders.map { $0.name ?? "Sem nome" }.joined(separator: ", "))")
        lines.append("")

        // Separa por status
        let naoPostados = posts.filter { $0.status == PostStatus.not_posted.rawValue }
        let postados = posts.filter { $0.status == PostStatus.posted.rawValue }

        // Dentro dos não postados, separa futuros e atrasados, e ordena por data
        let naoPostadosOrdenados = naoPostados.sorted {
            ($0.publishDate ?? .distantFuture) < ($1.publishDate ?? .distantFuture)
        }

        let atrasados = naoPostadosOrdenados.filter { ($0.publishDate ?? .distantFuture) < now }
        let futuros = naoPostadosOrdenados.filter { ($0.publishDate ?? .distantFuture) >= now }

        func formatPost(_ post: Post) -> String {
            let titulo = post.title ?? "Sem título"
            let plataforma = post.plataform ?? "?"
            let data = post.publishDate.map { df.string(from: $0) } ?? "sem data definida"
            let pasta = post.folder?.name ?? "sem pasta"
            return "- \"\(titulo)\" | \(plataforma) | data: \(data) | pasta: \(pasta)"
        }

        lines.append("POSTS NÃO POSTADOS E ATRASADOS (data já passou, prioridade máxima), ordenados do mais antigo para o mais recente:")
        lines.append(atrasados.isEmpty ? "Nenhum." : atrasados.map(formatPost).joined(separator: "\n"))
        lines.append("")

        lines.append("POSTS NÃO POSTADOS E FUTUROS (ainda vai acontecer), ordenados do mais próximo para o mais distante:")
        lines.append(futuros.isEmpty ? "Nenhum." : futuros.map(formatPost).joined(separator: "\n"))
        lines.append("")

        lines.append("POSTS JÁ POSTADOS (\(postados.count) no total):")
        lines.append(postados.isEmpty ? "Nenhum." : postados.map(formatPost).joined(separator: "\n"))

        return lines.joined(separator: "\n")
    }
    // MARK: - Private

    private func execute(action: AIAction) async throws -> String {
        switch action {

        case .createFolder(let payload):
            folderService.createFolder(name: payload.name, context: context)
            try postService.save(context: context)
            return "📁 Pasta \"\(payload.name)\" criada com sucesso!"

        case .createPost(let payload):
            var folder: Folder? = nil
            if let folderName = payload.folderName {
                folder = folderService.find(byName: folderName, context: context)
            }

            postService.createPost(
                title: payload.title,
                script: payload.script ?? "",
                plataform: Plataform(rawValue: payload.plataform) ?? .instagram,
                status: PostStatus(rawValue: payload.status) ?? .not_posted,
                publishDate: parseDate(payload.publishDate),
                briefing: payload.briefing,
                folder: folder,
                context: context
            )
            print("antes do save")
            
            do {
                try postService.save(context: context)
                print("Save OK")
            } catch let error as NSError {
                print("CoreData save error: \(error)")
                print("Detalhes: \(error.userInfo)")
                throw error
            }
            
            print("depois do save")
            let isCampaign = payload.briefing != nil
            var confirmation = "✅ Post \"\(payload.title)\" criado para \(payload.plataform)."
            if isCampaign { confirmation += " 🎯 Marcado como campanha." }
            if let folderName = payload.folderName { confirmation += " Adicionado à pasta \"\(folderName)\"." }
            print("cheguei no confirmation")
            return confirmation
        
        case .answerQuestion(let payload):
            return payload.answer
            
        case .unknown(let reason):
            return "🤔 Não entendi: \"\(reason)\". Tente algo como \"Crie uma pasta chamada Tech\" ou \"Crie um post para TikTok sobre receitas\"."
        }
    }

    private func parseDate(_ string: String?) -> Date? {
        guard let string else { return nil }
        return ISO8601DateFormatter().date(from: string)
    }
}
