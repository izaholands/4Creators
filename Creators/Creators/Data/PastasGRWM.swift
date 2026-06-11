//
//  File.swift
//  Creators
//
//  Created by Academy on 10/06/26.
//

import Foundation
import SwiftUI

struct StatusItemGRWM {
    let icone: String
    let cor: Color
    let texto: String
}

struct PastaGRWM: Identifiable {
    let id = UUID()
    var titulo: String
    var plataforma: String
    var status: [StatusItemGRWM]
    var data: String
    var hora: String
    let podeabrir: Bool
}

struct SearchProviderGRWM {
    static func all() -> [PastaGRWM] {
        return [
            PastaGRWM(
                titulo: "GRWM para passear",
                plataforma: "Story",
                status: [
                    StatusItemGRWM(icone: "arrow.down.circle", cor: .red, texto: "Não postado"),
                ],
                data: "10 de junho",
                hora: "15:00",
                podeabrir: true
            ),
            PastaGRWM(
                titulo: "GRWM com roupas novas",
                plataforma: "Tiktok",
                status:[
                    StatusItemGRWM(icone: "arrow.down.circle", cor: .red, texto: "Não postado"),
                ],
                data: "10 de junho",
                hora: "15:00",
                podeabrir: false
            ),
            PastaGRWM(
                titulo: "GRWM para academia",
                plataforma: "Story",
                status:[
                    StatusItemGRWM(icone: "arrow.up.circle", cor: .green, texto: "Postado"),
                ],
                data: "10 de junho",
                hora: "15:00",
                podeabrir: false
            ),
            PastaGRWM(
                titulo: "GRWM com o meu namorado",
                plataforma: "Reels",
                status:[
                    StatusItemGRWM(icone: "arrow.up.circle", cor: .green, texto: "Postado"),
                ],
                data: "10 de junho",
                hora: "15:00",
                podeabrir: false
            )
            
        ]
    }
}
