//
//  AgenticAction.swift
//  Creators
//
//  Created by admin on 10/06/26.
//


import Foundation

/// Representa uma ação que o agente pode executar no app.
enum AIAction: Decodable {
    case createPost(CreatePostPayload)
    case createFolder(CreateFolderPayload)
    case answerQuestion(AnswerPayload)
    case unknown(reason: String)

    
    struct CreatePostPayload: Decodable {
        let title: String
        let plataform: String       // "instagram" | "tiktok" | "youtube"
        let status: String         // posted | not_posted
        let script: String?
        let briefing: String?
        let folderName: String?
        let publishDate: String?   // ISO8601 ou nil
    
    }

    struct CreateFolderPayload: Decodable {
        let name: String
    }
    
    struct AnswerPayload: Decodable {  // novo
            let answer: String
    }

    private enum CodingKeys: String, CodingKey {
        case action, payload, reason
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = try container.decode(String.self, forKey: .action)

        switch action {
        
        case "create_post":
            let payload = try container.decode(CreatePostPayload.self, forKey: .payload)
            self = .createPost(payload)
        case "create_folder":
            let payload = try container.decode(CreateFolderPayload.self, forKey: .payload)
            self = .createFolder(payload)
        
        case "answer_question":  // novo
           let payload = try container.decode(AnswerPayload.self, forKey: .payload)
           self = .answerQuestion(payload)
       
        default:
            let reason = (try? container.decode(String.self, forKey: .reason)) ?? action
            self = .unknown(reason: reason)
        }
    }
}
