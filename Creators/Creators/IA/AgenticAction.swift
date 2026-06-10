//
//  AgenticAction.swift
//  Creators
//
//  Created by admin on 10/06/26.
//

import Foundation

enum AgentAction {

    case createPost(title: String, plataform: Plataform)

    case createFolder(name: String)

    case movePost(postTitle: String, folderName: String)

    case unknown
}
