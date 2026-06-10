//
//  WeekCalendarView.swift
//  Creators
//
//  Created by academy on 09/06/26.
//

import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    @State private var weekOffset: Int = 0

    private let calendar = Calendar.current
    private let weekdayNames = ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SÁB"]

    private var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1) + (weekOffset * 7),
            to: today
        )!
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            // Seta esquerda
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    weekOffset -= 1
                    selectedDate = weekDays.first.flatMap {
                        calendar.date(byAdding: .day, value: -7, to: $0)
                    } ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(.systemGray))
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 20)
            }
            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let dayNumber = calendar.component(.day, from: date)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDate = date
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(weekdayNames[index])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isSelected ? .white : Color(.systemGray))

                        Text("\(dayNumber)")
                            .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? .white : Color(.label))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.indigo : Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }

            // Seta direita
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    weekOffset += 1
                    selectedDate = weekDays.first.flatMap {
                        calendar.date(byAdding: .day, value: 7, to: $0)
                    } ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.systemGray))
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 20)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if value.translation.width < 0 {
                            weekOffset += 1
                            selectedDate = weekDays.first.flatMap {
                                calendar.date(byAdding: .day, value: 7, to: $0)
                            } ?? selectedDate
                        } else {
                            weekOffset -= 1
                            selectedDate = weekDays.first.flatMap {
                                calendar.date(byAdding: .day, value: -7, to: $0)
                            } ?? selectedDate
                        }
                    }
                }
        )
    }
}
