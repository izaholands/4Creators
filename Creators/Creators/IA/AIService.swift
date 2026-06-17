//
//  AgenticService.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation

final class AIService {

    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String = APIConfig.openAIKey) {
        self.apiKey = apiKey
    }

    func interpret(userMessage: String, contextSumary: String) async throws -> AIAction {
        let body = buildRequestBody(userMessage: userMessage, contextSumary: contextSumary)
        print(body)
        let data = try await performRequest(body: body)
        return try parseAction(from: data)
    }

    // MARK: - Private

    private func buildRequestBody(userMessage: String, contextSumary: String) -> [String: Any] {
        let fullSystemPrompt = systemPrompt + "\n\nDADOS ATUAIS DO USUÁRIO:\n\(contextSumary)"
        return [
            "model": "gpt-4o-mini",
            "temperature": 0.8,
            "messages": [
                ["role": "system", "content": fullSystemPrompt],
                ["role": "user", "content": userMessage]
            ]
        ]
    }

    private func performRequest(body: [String: Any]) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("cheguei aqui")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AIError.badResponse
        }

        return data
    }

    private func parseAction(from data: Data) throws -> AIAction {
        // Extrai o content da resposta da OpenAI
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Resposta completa da OpenAI:\n\(rawString)")
            }
        guard
            let choices = json?["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String,
            let contentData = content.data(using: .utf8)
        else {
            throw AIError.invalidResponse
            print("cai no else do invalid response")
        }
        print("contentData: \n\(content)")
        
        do {
                return try JSONDecoder().decode(AIAction.self, from: contentData)
            } catch {
                print("Erro no decode:\n\(error)")
                throw error
            }
        //return try JSONDecoder().decode(AIAction.self, from: contentData)
    }
}

// MARK: - System Prompt

private let systemPrompt = """
Você é um agente de organização de conteúdo para criadores de conteúdo digital.

Sua única função é interpretar comandos em português e retornar um JSON estruturado representando uma ação a ser executada no app.

AÇÕES DISPONÍVEIS:

1. Criar pasta:
{
  "action": "create_folder",
  "payload": {
    "name": "Nome da Pasta"
  }
}

2. Criar post:
{
  "action": "create_post",
  "payload": {
    "title": "Título do post",
    "plataform": "Instagram" | "TikTok" | "YouTube",
    "status": "not_posted" | "posted" ",
    "script": "roteiro gerado por você (obrigatório)",
    "briefing": "briefing opcional (apenas se for campanha)",
    "folderName": "nome da pasta opcional",
    "publishDate": "2024-06-15T10:00:00Z" | null
  }
}

3. Responder pergunta sobre os dados do usuário:
{ "action": "answer_question", "payload": { "answer": "sua resposta em português, baseada nos DADOS ATUAIS DO USUÁRIO fornecidos" } }

4. Ação desconhecida:
{
  "action": "unknown",
  "reason": "Não entendi o comando"
}

REGRAS GERAIS:
- Retorne APENAS o JSON, sem texto adicional, sem markdown, sem explicações.
- Se o usuário não especificar plataforma, use "instagram".
- Se a mensagem for um COMANDO para criar algo, use create_post ou create_folder normalmente.
- Se a pergunta tiver a ver com datas, leve em consideração a data atual e a data de publicação. Informe se existem conteúdos atrasados.
- Se a mensagem do usuário for uma PERGUNTA sobre os posts/pastas dele (quantos, quais, status, datas, etc), use "answer_question" e responda com base nos DADOS ATUAIS DO USUÁRIO informados no contexto.
- Se o usuário não especificar status, use "not_posted".
- Se mencionar patrocínio, marca ou campanha, preencha o campo "briefing" com os detalhes informados.
- publishDate deve estar em ISO8601 ou null se não informado.
- status deve ser EXATAMENTE um destes valores: "not_posted" ou "posted". Nunca invente outros valores. Para conteúdos novos use "not_posted".
- Os dados fornecidos já vêm organizados por categoria (atrasados, futuros, postados) e ordenados por data. Use essa ordem como prioridade ao responder perguntas como "o que devo postar primeiro" ou "qual o próximo post".
- Posts "atrasados" são aqueles cuja data já passou e ainda não foram postados — trate-os como prioridade máxima nas respostas.
- Sempre baseie suas respostas na DATA E HORA ATUAL fornecida no contexto, não assuma datas.

REGRAS DO ROTEIRO (campo "script"):
- O campo "script" é SEMPRE obrigatório ao criar um post. Nunca retorne null.
- Gere um roteiro curto e prático baseado no título e plataforma informados.
- Adapte o formato ao estilo de cada plataforma:

  Instagram Reels / TikTok:
   Gancho: [frase de impacto para os primeiros 3 segundos]
   Desenvolvimento: [2 a 3 tópicos rápidos]
   CTA: [chamada para ação — salvar, comentar, seguir]

  YouTube:
    Gancho: [pergunta ou afirmação impactante]
    Introdução: [contexto rápido — 30 segundos]
    Desenvolvimento: [3 a 5 tópicos principais]
    CTA: [inscrever, curtir, comentar]

- Faça um roteiro bem estruturado e focado para o que o usuario quer. Se ele não falar nada, leve em consideração que é com a finalidade de ganhar seguidores.
- Escreva em português, de forma direta e prática.
- Se o usuário já informar partes do roteiro no comando, incorpore-as.
"""

// MARK: - Errors

enum AIError: LocalizedError {
    case badResponse
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .badResponse: return "Erro na comunicação com a IA."
        case .invalidResponse: return "A IA retornou uma resposta inválida."
        }
    }
}
