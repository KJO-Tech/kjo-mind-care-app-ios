//
//  MoodsView.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import SwiftUI

struct MoodsView: View {

    @StateObject private var viewModel = DIContainer.shared.container.resolve(MoodsViewModel.self)!

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
                        historyCardSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    viewModel.loadData()
                    viewModel.loadHistory(reset: true)
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
            .onAppear {
                viewModel.loadData()
                viewModel.loadHistory(reset: true)
            }
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
                        color: Color(hex: item.colorHex) ?? Color.theme.secondary
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

    private var historyCardSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(String(localized: "mood.history.title"))
                .font(Font.theme.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.text)

            if viewModel.historyEntries.isEmpty && !viewModel.isLoadingHistory {
                Text(String(localized: "mood.history.empty"))
                    .font(Font.theme.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.historyEntries) { entry in
                        MoodHistoryRow(entry: entry)
                    }

                    if viewModel.canLoadMore {
                        Button(action: {
                            viewModel.loadHistory()
                        }) {
                            if viewModel.isLoadingHistory {
                                ProgressView()
                            } else {
                                Text(String(localized: "common.load_more"))
                                    .font(Font.theme.body.bold())
                                    .foregroundColor(Color.theme.primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.theme.card)
        .cornerRadius(20)
    }
}

struct MoodHistoryRow: View {
    let entry: MoodHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            // Mood Image
            AsyncImage(url: URL(string: entry.moodImage)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "face.smiling")  // Fallback
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(hex: entry.moodColorHex) ?? .gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 40, height: 40)
            .padding(.leading, 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.moodName)
                    .font(Font.theme.body.bold())
                    .foregroundColor(Color.theme.text)

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Font.theme.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .opacity(0.8)

                if !entry.note.isEmpty {
                    Text("\"\(entry.note)\"")
                        .font(Font.theme.caption)
                        .italic()
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            Color(hex: entry.moodColorHex).opacity(0.1) ?? Color.theme.surface
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color(hex: entry.moodColorHex).opacity(0.2) ?? Color.clear,
                    lineWidth: 1)
        )
    }
}

struct MoodsView_Previews: PreviewProvider {
    static var previews: some View {
        MoodsView()
    }
}
