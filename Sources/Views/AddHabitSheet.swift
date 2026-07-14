import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: HabitStore
    
    @State private var title = ""
    @State private var selectedIcon = "brain.headlight.fill"
    @State private var selectedColor = "#6366F1"
    
    let icons = [
        "brain.headlight.fill", "drop.fill", "book.closed.fill", "figure.run",
        "bed.double.fill", "heart.fill", "cup.and.saucer.fill", "checkmark.seal.fill",
        "dumbbell.fill", "music.note", "pencil.and.outline", "leaf.fill"
    ]
    
    let colors = [
        "#6366F1", // Indigo
        "#3B82F6", // Blue
        "#10B981", // Green
        "#F59E0B", // Yellow/Orange
        "#EF4444", // Red
        "#EC4899", // Pink
        "#8B5CF6", // Purple
        "#06B6D4"  // Cyan
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("习惯名称，例如：阅读、健身", text: $title)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("选择图标")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.15) : Color(.secondarySystemBackground))
                                    .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .primary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("选择主题色")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { hexColor in
                            Button {
                                selectedColor = hexColor
                            } label: {
                                Circle()
                                    .fill(Color(hex: hexColor))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == hexColor ? Color.primary : Color.clear, lineWidth: 2)
                                            .frame(width: 42, height: 42)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("添加新习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleanTitle.isEmpty {
                            store.addHabit(title: cleanTitle, icon: selectedIcon, colorHex: selectedColor)
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddHabitSheet()
        .environmentObject(HabitStore())
}
