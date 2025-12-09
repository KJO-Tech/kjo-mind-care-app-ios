//
//  MoodsView.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import SwiftUI

struct MoodsView: View {

    @StateObject private var viewModel = MoodsViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        headerSection
                        timeframeSelector
                        chartCardSection
                        insightsCardSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            //            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private var headerSection: some View {
        HStack {
            Text("Mood Tracker")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            NavigationLink(destination: RecordMoodView()) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                    Text(String(localized: "Registrar Estado"))
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
    }

    private var timeframeSelector: some View {
        HStack {
            Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(viewModel.timeframes, id: \.self) { timeframe in
                    Text(timeframe).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor =
                    UIColor(Color.gray.opacity(0.6))
                UISegmentedControl.appearance().backgroundColor = UIColor(
                    Color.gray.opacity(0.2))
                UISegmentedControl.appearance().setTitleTextAttributes(
                    [.foregroundColor: UIColor.white], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes(
                    [.foregroundColor: UIColor.lightGray], for: .normal)
            }
            Spacer()
        }
        .frame(width: 160)
    }

    private var chartCardSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mood Trends")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            MoodTrendChart(data: viewModel.chartData)
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }

    private var insightsCardSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Your Insights")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(alignment: .top) {
                insightStatItem(
                    title: String(localized: "Mas frecuente"),
                    value: viewModel.mostFrequentMood, icon: nil,
                    valueColor: .white)
                Spacer()
                insightStatItem(
                    title: "Mood Trend", value: viewModel.moodTrend,
                    icon: "chart.line.uptrend.xyaxis", valueColor: .gray)
                Spacer()
                insightStatItem(
                    title: String(localized: "Estado general"),
                    value: viewModel.overallMood, icon: nil, valueColor: .white)
            }

            Divider().background(Color.white.opacity(0.2))

            VStack(alignment: .leading, spacing: 15) {
                Text("Mood Distribution")
                    .font(.headline)
                    .foregroundColor(.white)

               
                ForEach(viewModel.distributionData) { item in
                    MoodDistributionRow(
                        item: item,
                        color: getColorForEmotion(item.emotion)
                    )
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
    
    

    
    private func insightStatItem(
        title: String, value: String, icon: String?, valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 5) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.caption)
                }
                Text(value)
                    .font(.headline)

            }
            .foregroundColor(valueColor)
        }
        .frame(minWidth: 80, alignment: .leading)
    }
}

struct MoodsView_Previews: PreviewProvider {
    static var previews: some View {
        MoodsView()
    }
}
