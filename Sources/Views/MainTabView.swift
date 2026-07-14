import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: HabitStore
    
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("今天", systemImage: "sparkles")
            }
            
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("趋势", systemImage: "chart.bar.fill")
            }
        }
        .tint(Color(hex: "#6366F1")) // Accent Indigo
    }
}

#Preview {
    MainTabView()
        .environmentObject(HabitStore())
}
