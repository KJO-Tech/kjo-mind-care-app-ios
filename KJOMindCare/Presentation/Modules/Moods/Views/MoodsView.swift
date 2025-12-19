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
                Color.theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {

                        timeframeSelector
                        chartCardSection
                        insightsCardSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(String(localized: "mood.tracker.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: RecordMoodView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.primary)
                    }
                }
            }
            //            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }



    private var timeframeSelector: some View {
        HStack {
            Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(viewModel.timeframes, id: \.self) { timeframe in
                    Text(timeframe).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            Spacer()
        }
        .frame(width: 160)
    }

    private var chartCardSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(String(localized: "mood.trends.title"))
                .font(Font.theme.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.text)

            MoodTrendChart(data: viewModel.chartData)
        }
        .padding(20)
        .background(Color.theme.card)
        .cornerRadius(20)
    }

    private var insightsCardSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(String(localized: "mood.insights.title"))
                .font(Font.theme.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.text)

            HStack(alignment: .top) {
                insightStatItem(
                    title: String(localized: "mood.stats.mostFrequent"),
                    value: viewModel.mostFrequentMood, icon: nil,
                    valueColor: Color.theme.text)
                Spacer()
                insightStatItem(
                    title: String(localized: "mood.stats.trend"), value: viewModel.moodTrend,
                    icon: "chart.line.uptrend.xyaxis", valueColor: Color.theme.textSecondary)
                Spacer()
                insightStatItem(
                    title: String(localized: "mood.stats.overall"),
                    value: viewModel.overallMood, icon: nil, valueColor: Color.theme.text)
            }

            Divider().background(Color.theme.border)

            VStack(alignment: .leading, spacing: 15) {
                Text(String(localized: "mood.stats.distribution"))
                    .font(Font.theme.headline)
                    .foregroundColor(Color.theme.text)

                ForEach(viewModel.distributionData) { item in
                    MoodDistributionRow(
                        item: item,
                        color: getColorForEmotion(item.emotion)
                    )
                }
            }
        }
        .padding(20)
        .background(Color.theme.card)
        .cornerRadius(20)
    }

    private func insightStatItem(
        title: String, value: String, icon: String?, valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.theme.subheadline)
                .foregroundColor(Color.theme.textSecondary)

            HStack(spacing: 5) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(Font.theme.caption)
                }
                Text(value)
                    .font(Font.theme.headline)

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
