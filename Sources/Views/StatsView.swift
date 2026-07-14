import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var store: HabitStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MIND & HABIT STATS")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Text("统计与分析")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Card 1: Mood Line Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("心情趋势 (近7天)")
                        .font(.headline)
                    
                    if store.moodHistory.isEmpty {
                        Text("还没有心情数据，快去主页记录吧")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 180)
                    } else {
                        Chart {
                            ForEach(store.moodHistory.suffix(7)) { entry in
                                LineMark(
                                    x: .value("日期", entry.date, unit: .day),
                                    y: .value("心情", entry.level)
                                )
                                .interpolationMethod(.catmullRom)
                                .lineStyle(StrokeStyle(lineWidth: 4))
                                .foregroundStyle(Color(hex: "#6366F1"))
                                
                                PointMark(
                                    x: .value("日期", entry.date, unit: .day),
                                    y: .value("心情", entry.level)
                                )
                                .foregroundStyle(Color(hex: "#6366F1"))
                                .annotation(position: .top) {
                                    Text(entry.emoji)
                                        .font(.system(size: 14))
                                }
                                
                                AreaMark(
                                    x: .value("日期", entry.date, unit: .day),
                                    y: .value("心情", entry.level)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(LinearGradient(
                                    colors: [Color(hex: "#6366F1").opacity(0.3), Color(hex: "#6366F1").opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .frame(height: 180)
                        .chartYScale(range: .plotDimension(padding: 12))
                        .chartYAxis {
                            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                                AxisValueLabel {
                                    if let intValue = value.as(Int.self) {
                                        switch intValue {
                                        case 1: Text("😔")
                                        case 3: Text("😊")
                                        case 5: Text("🔥")
                                        default: Text("")
                                        }
                                    }
                                }
                                AxisGridLine()
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisValueLabel(format: .dateTime.day().month())
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground).opacity(0.4))
                )
                .padding(.horizontal)
                
                // MARK: - Card 2: Habit Completion Rate Bar Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("习惯完成率 (近7天)")
                        .font(.headline)
                    
                    if store.dailyHistory.isEmpty {
                        Text("还没有打卡记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 180)
                    } else {
                        Chart {
                            ForEach(store.dailyHistory.suffix(7)) { entry in
                                BarMark(
                                    x: .value("日期", entry.date, unit: .day),
                                    y: .value("完成率", entry.rate * 100)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#10B981"), Color(hex: "#3B82F6")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                                AxisValueLabel {
                                    if let pct = value.as(Int.self) {
                                        Text("\(pct)%")
                                    }
                                }
                                AxisGridLine()
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisValueLabel(format: .dateTime.day().month())
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground).opacity(0.4))
                )
                .padding(.horizontal)
                
                // MARK: - Card 3: Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCard(title: "最佳连续", value: "\(store.habits.map { $0.streak }.max() ?? 0)天", icon: "flame.fill", color: "#EF4444")
                    MetricCard(title: "今日表现", value: "\(Int(store.completionRateToday * 100))%", icon: "checkmark.circle.fill", color: "#10B981")
                    MetricCard(title: "累计心情打卡", value: "\(store.moodHistory.count)次", icon: "heart.fill", color: "#EC4899")
                    MetricCard(title: "习惯数量", value: "\(store.habits.count)项", icon: "list.bullet.clipboard.fill", color: "#3B82F6")
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationBarHidden(true)
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var icon: String
    var color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: color))
                Spacer()
            }
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground).opacity(0.4))
        )
    }
}

#Preview {
    StatsView()
        .environmentObject(HabitStore())
}
