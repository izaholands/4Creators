//
//  HomeView.swift
//  Creators
//
//  Created by academy on 09/06/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate: Date = Date()
    @State private var showAISheet = false

    private var selectedDateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        let raw = formatter.string(from: selectedDate)
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // Botão Peça à IA
                Button {
                    showAISheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 18, weight: .bold))
                        Text("Peça à IA")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 358, height: 88)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.indigo)
                    )
                }
                .buttonStyle(.plain)

                // Seção publicações
                VStack(alignment: .leading, spacing: 14) {

                    Text("Próximas publicações")
                        .font(.system(size: 22, weight: .bold))

                    WeekCalendarView(selectedDate: $selectedDate)

                    Text(selectedDateLabel)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)

                    // Posts virão aqui — outra pessoa implementa
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(Color(.systemGray3))
                        Text("Nenhuma publicação para este dia")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.systemGray))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAISheet){
            AISheetView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}

#Preview {
    HomeView()
}
