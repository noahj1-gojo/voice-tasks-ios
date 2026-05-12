import SwiftUI

struct TaskRowView: View {
    let item: TaskItem
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void

    private let accent = Color(hex: "007AFF")

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button { onToggle(item) } label: {
                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(item.done ? accent : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(item.done ? .secondary : .primary)
                    .strikethrough(item.done, color: .secondary)
                    .lineLimit(3)

                if let desc = item.taskDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                if item.date != nil || item.time != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        if let d = item.date { Text(d) }
                        if let t = item.time { Text("·"); Text(t) }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { onDelete(item) } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}
