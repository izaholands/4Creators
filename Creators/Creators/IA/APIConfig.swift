//
//  APIConfig.swift
//  Creators
//
//  Created by admin on 11/06/26.
//

import Foundation

enum APIConfig {
    static var openAIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("OPENAI_API_KEY não encontrada no Info.plist")
        }
        return key
    }
}
