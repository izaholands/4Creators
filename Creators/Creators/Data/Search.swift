//
//  Search.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import Foundation
import SwiftUI

struct StatusItemPublis {
    let icone: String
    let cor: Color
    let texto: String
}

struct SearchDetails: Identifiable {
    let id = UUID()
    var titulo: String
    var plataforma: String
    var status: [StatusItemPublis]
    var data: String
    var hora: String
}

struct SearchProvider {
    static func all() -> [SearchDetails] {
        return [
            SearchDetails(
                titulo: "Creamy protetor solar",
                plataforma: "Story",
                status: [
                    StatusItemPublis(icone: "arrow.down.circle", cor: .red, texto: "Não postado"),
                ],
                data: "12 de junho",
                hora: "18:00"
            ),
            SearchDetails(
                titulo: "Receita fitness",
                plataforma: "Youtube",
                status:[
                    StatusItemPublis(icone: "arrow.down.circle", cor: .red, texto: "Não postado"),
                ],
                data: "12 de junho",
                hora: "15:00"
            ),
            SearchDetails(
                titulo: "GRWM para academia",
                plataforma: "Tiktok",
                status:[
                    StatusItemPublis(icone: "arrow.up.circle", cor: .green, texto: "Postado"),
                ],
                data: "10 de junho",
                hora: "15:00"
            )
        ]
    }
}
