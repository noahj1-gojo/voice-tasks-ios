import SwiftUI

struct TaskBoardView: View {
    let items: [TaskItem]
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onSelectType: (TaskType) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(TaskType.allCases, id: \.self) { type in
                CategoryCardView(
                    type: type,
                    items: items.filter { $0.type == type.rawValue },
                    onToggle: onToggle,
                    onDelete: onDelete,
                    onSelect: { onSelectType(type) }
                )
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
}
