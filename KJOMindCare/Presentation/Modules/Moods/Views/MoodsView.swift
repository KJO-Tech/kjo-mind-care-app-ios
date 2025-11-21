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
        ZStack {
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
       
    }
    
   
    
    private var headerSection: some View {
        HStack {
            Text("Mood Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            
            Button(action: {
                print("Record Mood Tapped")
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                    Text("Record Mood")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(
                    LinearGradient(colors: [Color.gray.opacity(0.8), Color.gray], startPoint: .leading, endPoint: .trailing)
                )
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
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.gray)
                UISegmentedControl.appearance().backgroundColor = UIColor(Color.gray)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
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
        .background(Color.secondary)
        .cornerRadius(20)
    }
    
    private var insightsCardSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Your Insights")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
           
            HStack(alignment: .top) {
                insightStatItem(title: "Most Frequent", value: viewModel.mostFrequentMood, icon: nil, valueColor: .white)
                Spacer()
               
                insightStatItem(title: "Mood Trend", value: viewModel.moodTrend, icon: "chart.line.uptrend.xyaxis", valueColor: .secondary)
                Spacer()
                insightStatItem(title: "Overall Mood", value: viewModel.overallMood, icon: nil, valueColor: .white)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
           
            VStack(alignment: .leading, spacing: 15) {
                Text("Mood Distribution")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(viewModel.distributionData) { item in
                   
                    MoodDistributionRow(item: item)
                }
            }
        }
        .padding(20)
        .background(Color.gray)
        .cornerRadius(20)
    }
    

    private func insightStatItem(title: String, value: String, icon: String?, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
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

#Preview {
    MoodsView()
}
