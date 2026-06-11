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
        let action = try await aiService.interpret(userMessage: userMessage)
        print("action: \(action)")
        return try await execute(action: action)
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

        case .unknown(let reason):
            return "🤔 Não entendi: \"\(reason)\". Tente algo como \"Crie uma pasta chamada Tech\" ou \"Crie um post para TikTok sobre receitas\"."
        }
    }

    private func parseDate(_ string: String?) -> Date? {
        guard let string else { return nil }
        return ISO8601DateFormatter().date(from: string)
    }
}
