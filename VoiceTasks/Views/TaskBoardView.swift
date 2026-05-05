import SwiftUI

struct TaskBoardView: View {
    let items: [TaskItem]
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onSelectType: (TaskType) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(TaskType.allCases, id: \.self) { type in
                CategoryCardView(
                    type: type,
                    items: items.filter { $0.type == type.rawValue },
                    onToggle: onToggle,
                    onDelete: onDelete,
                    onSelect: { onSelectType(type) }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}
