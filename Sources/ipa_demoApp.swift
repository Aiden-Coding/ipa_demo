import SwiftUI

@main
struct ipa_demoApp: App {
    @StateObject private var store = HabitStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
