import SwiftUI

struct CategoryCardView: View {
    let type: TaskType
    let items: [TaskItem]
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var cardBackground: Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : .white
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().padding(.horizontal, 14)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0 : 0.07),
            radius: 8, x: 0, y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(type.color.opacity(0.18), lineWidth: 1)
        )
    }

    private var header: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(type.color)
                Text(type.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                if !items.isEmpty {
                    Text("\(items.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.12))
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        if items.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(type.color.opacity(0.25))
                Text("Noch nichts hier")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 22)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(items, id: \.id) { item in
                        TaskRowView(item: item, onToggle: onToggle, onDelete: onDelete)
                        if item.id != items.last?.id {
                            Divider().padding(.leading, 42)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct TaskRowView: View {
    let item: TaskItem
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button { onToggle(item) } label: {
                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(item.done ? item.taskType.color : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(item.done ? .secondary : .primary)
                    .strikethrough(item.done, color: .secondary)
                    .lineLimit(2)

                if let desc = item.taskDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
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
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { onDelete(item) } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}
