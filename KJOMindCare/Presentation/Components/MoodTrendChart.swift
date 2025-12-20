//
//  MoodTrendChart.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Charts
import SwiftUI

struct MoodTrendChart: View {
    let data: [MoodChartPoint]

    var body: some View {

        Chart(data) { point in

            LineMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.theme.primary)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .foregroundStyle(Color(hex: point.colorHex ?? "") ?? Color.theme.textSecondary)
            .symbolSize(100)
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 1, 2, 3, 4, 5]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.theme.border)

                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .foregroundColor(Color.theme.textSecondary)
                            .font(Font.theme.caption)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
                            .foregroundColor(Color.theme.textSecondary)
                            .font(Font.theme.caption)
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MoodTrendChart(data: [
            MoodChartPoint(day: "Lun", value: 1),
            MoodChartPoint(day: "Mar", value: 3),
            MoodChartPoint(day: "Mie", value: 2),
            MoodChartPoint(day: "Jue", value: 4),
            MoodChartPoint(day: "Vie", value: 2),
        ])
        .padding()
    }
}
