import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showingAddHabit = false
    
    // Mood list definition
    private let moods = [
        (emoji: "😔", name: "低落", level: 1, color: "#6B7280"),
        (emoji: "😐", name: "平淡", level: 2, color: "#9CA3AF"),
        (emoji: "😊", name: "愉悦", level: 3, color: "#10B981"),
        (emoji: "🧘", name: "平静", level: 4, color: "#6366F1"),
        (emoji: "🔥", name: "充沛", level: 5, color: "#EC4899")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MINDFLOW")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Text(greetingText())
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                    }
                    Spacer()
                    
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color(hex: "#6366F1").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Today's Mood Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("今天感觉如何？")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.level) { mood in
                                let isSelected = store.todayMood?.level == mood.level
                                
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        store.logTodayMood(emoji: mood.emoji, level: mood.level)
                                    }
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(mood.emoji)
                                            .font(.system(size: 32))
                                        Text(mood.name)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                    }
                                    .frame(width: 64, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(isSelected ? Color(hex: mood.color).opacity(0.15) : Color(.secondarySystemBackground).opacity(0.5))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSelected ? Color(hex: mood.color) : Color.clear, lineWidth: 2)
                                    )
                                    .scaleEffect(isSelected ? 1.08 : 1.0)
                                    .foregroundColor(isSelected ? Color(hex: mood.color) : .secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Habit Progress Ring
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日打卡进度")
                                .font(.headline)
                            Text("\(store.habits.filter { $0.isCompleted }.count) / \(store.habits.count) 已完成")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: 24) {
                        // Progress ring container
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray6), lineWidth: 16)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(store.completionRateToday, 1.0)))
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "#6366F1"), Color(hex: "#10B981")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.easeOut(duration: 0.8), value: store.completionRateToday)
                            
                            VStack(spacing: 2) {
                                Text("\(Int(store.completionRateToday * 100))%")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                Text("完成率")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle().fill(Color(hex: "#6366F1")).frame(width: 8, height: 8)
                                Text("今日目标数：\(store.habits.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Circle().fill(Color(hex: "#10B981")).frame(width: 8, height: 8)
                                Text("坚持最长：\(store.habits.map { $0.streak }.max() ?? 0)天")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("保持专注，不断进步！")
                                .font(.caption)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground).opacity(0.4))
                )
                .padding(.horizontal)
                
                // MARK: - Habit List Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("今日习惯")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if store.habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "square.dashed")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("目前没有设置习惯，点击右上角加号添加吧")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(store.habits) { habit in
                                HabitCard(habit: habit) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                        store.toggleHabit(id: habit.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddHabit) {
            AddHabitSheet()
        }
    }
    
    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "早上好，新的一天"
        } else if hour < 18 {
            return "下午好，继续保持"
        } else {
            return "晚上好，回顾今天"
        }
    }
}

// MARK: - Habit Card Component
struct HabitCard: View {
    var habit: Habit
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Icon block
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: habit.colorHex).opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: habit.colorHex))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(habit.streak) 天连续")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Completed Check Button
                ZStack {
                    Circle()
                        .stroke(habit.isCompleted ? Color.clear : Color(hex: habit.colorHex).opacity(0.4), lineWidth: 2)
                        .fill(habit.isCompleted ? Color(hex: habit.colorHex) : Color.clear)
                        .frame(width: 28, height: 28)
                    
                    if habit.isCompleted {
                        Image(systemName: "check")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground).opacity(0.6))
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
            .scaleEffect(habit.isCompleted ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
        .environmentObject(HabitStore())
}
