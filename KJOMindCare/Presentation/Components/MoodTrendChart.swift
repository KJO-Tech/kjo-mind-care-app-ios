//
//  MoodTrendChart.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import SwiftUI
import Charts

struct MoodTrendChart: View {
    let data: [MoodChartPoint]
    
    var body: some View {
       
        Chart(data) { point in
            
            
            LineMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.blue)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            // 2. Los Puntos
            PointMark(
                x: .value("Day", point.day),
                y: .value("Value", point.value)
            )
            .foregroundStyle(Color.gray)
            .symbolSize(100)
        }
        // Configuración del Eje Y (Vertical)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 1, 2, 3, 4]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.white.opacity(0.2))
                
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        // Configuración del Eje X (Horizontal)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

// MARK: - Preview para verificar que funciona
#Preview {
    ZStack {
        Color.black.ignoresSafeArea() // Fondo oscuro para ver los colores claros
        MoodTrendChart(data: [
            MoodChartPoint(day: "Lun", value: 1),
            MoodChartPoint(day: "Mar", value: 3),
            MoodChartPoint(day: "Mie", value: 2),
            MoodChartPoint(day: "Jue", value: 4),
            MoodChartPoint(day: "Vie", value: 2)
        ])
        .padding()
    }
}
//#Preview {
//    MoodTrendChart()
//}
