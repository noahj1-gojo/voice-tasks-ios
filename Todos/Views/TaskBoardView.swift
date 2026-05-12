import SwiftUI

struct TaskBoardView: View {
    let items: [TaskItem]
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var pending: [TaskItem] { items.filter { !$0.done } }
    private var completed: [TaskItem] { items.filter { $0.done } }

    private var listBackground: Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : .white
    }

    var body: some View {
        VStack(spacing: 16) {
            if items.isEmpty {
                emptyState
            } else {
                if !pending.isEmpty {
                    section(items: pending)
                }
                if !completed.isEmpty {
                    sectionHeader("Erledigt")
                    section(items: completed)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
    }

    private func section(items: [TaskItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.id) { item in
                TaskRowView(item: item, onToggle: onToggle, onDelete: onDelete)
                if item.id != items.last?.id {
                    Divider().padding(.leading, 42)
                }
            }
        }
        .background(listBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text("Noch keine Todos")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Text("Tippe auf das Mikrofon, um eines aufzunehmen.")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}
