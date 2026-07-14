import Foundation
import SwiftUI

// MARK: - Mood Entry
struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var emoji: String
    var level: Int // 1 (Worst) to 5 (Best)
}

// MARK: - Habit
struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var icon: String // SF Symbol Name
    var colorHex: String // e.g. "#4F46E5"
    var isCompleted: Bool
    var streak: Int
    var targetTimes: Int
    var completedTimes: Int
}

// MARK: - Daily Completion History
struct DailyCompletion: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var rate: Double // 0.0 to 1.0
}

// MARK: - Habit Store (ObservableObject)
class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            saveData()
        }
    }
    
    @Published var moodHistory: [MoodEntry] = [] {
        didSet {
            saveData()
        }
    }
    
    @Published var dailyHistory: [DailyCompletion] = [] {
        didSet {
            saveData()
        }
    }
    
    private let habitsKey = "mindflow_habits"
    private let moodKey = "mindflow_moods"
    private let historyKey = "mindflow_history"
    
    init() {
        loadData()
        if habits.isEmpty && moodHistory.isEmpty {
            loadMockData()
        }
    }
    
    // MARK: - Actions
    func toggleHabit(id: UUID) {
        if let index = habits.firstIndex(where: { $0.id == id }) {
            habits[index].isCompleted.toggle()
            if habits[index].isCompleted {
                habits[index].completedTimes = habits[index].targetTimes
                habits[index].streak += 1
            } else {
                habits[index].completedTimes = 0
                habits[index].streak = max(0, habits[index].streak - 1)
            }
            updateTodayCompletionRate()
        }
    }
    
    func addHabit(title: String, icon: String, colorHex: String) {
        let newHabit = Habit(
            title: title,
            icon: icon,
            colorHex: colorHex,
            isCompleted: false,
            streak: 0,
            targetTimes: 1,
            completedTimes: 0
        )
        habits.append(newHabit)
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }
    
    func logTodayMood(emoji: String, level: Int) {
        let calendar = Calendar.current
        let today = Date()
        
        // Remove existing today's mood if any
        moodHistory.removeAll { calendar.isDate($0.date, inSameDayAs: today) }
        
        let entry = MoodEntry(date: today, emoji: emoji, level: level)
        moodHistory.append(entry)
        
        // Sort history by date
        moodHistory.sort { $0.date < $1.date }
    }
    
    var todayMood: MoodEntry? {
        let calendar = Calendar.current
        return moodHistory.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }
    
    var completionRateToday: Double {
        guard !habits.isEmpty else { return 0.0 }
        let completed = habits.filter { $0.isCompleted }.count
        return Double(completed) / Double(habits.count)
    }
    
    private func updateTodayCompletionRate() {
        let calendar = Calendar.current
        let today = Date()
        let rate = completionRateToday
        
        if let index = dailyHistory.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            dailyHistory[index].rate = rate
        } else {
            dailyHistory.append(DailyCompletion(date: today, rate: rate))
        }
        dailyHistory.sort { $0.date < $1.date }
    }
    
    // MARK: - Persistence
    private func saveData() {
        let encoder = JSONEncoder()
        if let encodedHabits = try? encoder.encode(habits) {
            UserDefaults.standard.set(encodedHabits, forKey: habitsKey)
        }
        if let encodedMoods = try? encoder.encode(moodHistory) {
            UserDefaults.standard.set(encodedMoods, forKey: moodKey)
        }
        if let encodedHistory = try? encoder.encode(dailyHistory) {
            UserDefaults.standard.set(encodedHistory, forKey: historyKey)
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        if let savedHabits = UserDefaults.standard.data(forKey: habitsKey),
           let decodedHabits = try? decoder.decode([Habit].self, from: savedHabits) {
            self.habits = decodedHabits
        }
        if let savedMoods = UserDefaults.standard.data(forKey: moodKey),
           let decodedMoods = try? decoder.decode([MoodEntry].self, from: savedMoods) {
            self.moodHistory = decodedMoods
        }
        if let savedHistory = UserDefaults.standard.data(forKey: historyKey),
           let decodedHistory = try? decoder.decode([DailyCompletion].self, from: savedHistory) {
            self.dailyHistory = decodedHistory
        }
    }
    
    // MARK: - Mock Data Loading
    private func loadMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        // 1. Initial Habits
        self.habits = [
            Habit(title: "晨间冥想", icon: "brain.headlight.fill", colorHex: "#6366F1", isCompleted: true, streak: 5, targetTimes: 1, completedTimes: 1),
            Habit(title: "多喝水 (2L)", icon: "drop.fill", colorHex: "#3B82F6", isCompleted: false, streak: 3, targetTimes: 1, completedTimes: 0),
            Habit(title: "阅读 30分钟", icon: "book.closed.fill", colorHex: "#10B981", isCompleted: true, streak: 12, targetTimes: 1, completedTimes: 1),
            Habit(title: "户外跑步", icon: "figure.run", colorHex: "#F59E0B", isCompleted: false, streak: 0, targetTimes: 1, completedTimes: 0)
        ]
        
        // 2. Generate past 7 days moods & habit completion rate
        var mockMoods: [MoodEntry] = []
        var mockHistory: [DailyCompletion] = []
        
        let emojis = ["😔", "😐", "😊", "🧘", "🔥"]
        let levels = [1, 2, 3, 4, 5]
        
        for i in (1...7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Pre-fill history mood
                let moodIndex = Int.random(in: 2...4) // Mostly good moods
                mockMoods.append(MoodEntry(date: date, emoji: emojis[moodIndex], level: levels[moodIndex]))
                
                // Pre-fill history completion rate (60% to 100%)
                let randomRate = Double(Int.random(in: 3...5)) / 5.0
                mockHistory.append(DailyCompletion(date: date, rate: randomRate))
            }
        }
        
        self.moodHistory = mockMoods
        self.dailyHistory = mockHistory
        
        // Append today's history based on today's initial habits status
        updateTodayCompletionRate()
    }
}

// MARK: - Color Hex Helpers
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
