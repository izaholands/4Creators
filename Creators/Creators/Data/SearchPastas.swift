//
//  SearchDetails.swift
//  Creators
//
//  Created by Academy on 09/06/26.
//

import Foundation
import SwiftUI

struct StatusItem {
    let icone: String
    let cor: Color
    let texto: String
}

struct SearchPastas: Identifiable {
    let id = UUID()
    var nomepasta: String
    var status: [StatusItem]
    let podeabrir: Bool
}

struct SearchProviderPastas {
    static func all() -> [SearchPastas] {
        return [
            SearchPastas(
                nomepasta: "GRWM",
                status: [
                    StatusItem(
                        icone: "arrow.down.circle",
                        cor: .red,
                        texto: "4 itens não postados"),
                    StatusItem(
                        icone: "arrow.up.circle",
                        cor: .green,
                        texto: "2 itens postados"
                    )
                ],
                podeabrir: true
            ),
            SearchPastas(
                nomepasta: "Elseve",
                status: [
                    StatusItem(
                        icone: "arrow.down.circle",
                        cor: .red,
                        texto: "3 itens não postados"),
                    StatusItem(
                        icone: "arrow.up.circle",
                        cor: .green,
                        texto: "1 item postado"
                    )
                ],
                podeabrir: false
            ),
            SearchPastas(
                nomepasta: "Maquiagem",
                status: [
                    StatusItem(
                        icone: "arrow.down.circle",
                        cor: .red,
                        texto: "2 itens não postados"),
                    StatusItem(
                        icone: "arrow.up.circle",
                        cor: .green,
                        texto: "5 itens postados"
                    )
                ],
                podeabrir: false
            )
        ]
    }
}
