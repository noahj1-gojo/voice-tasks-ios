import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let type: TaskType
    let onToggle: (TaskItem) -> Void
    let onDelete: (TaskItem) -> Void

    @Query private var items: [TaskItem]

    init(type: TaskType, onToggle: @escaping (TaskItem) -> Void, onDelete: @escaping (TaskItem) -> Void) {
        self.type = type
        self.onToggle = onToggle
        self.onDelete = onDelete
        let rawType = type.rawValue
        _items = Query(
            filter: #Predicate<TaskItem> { $0.type == rawType },
            sort: \TaskItem.createdAt,
            order: .reverse
        )
    }

    private var pending: [TaskItem] { items.filter { !$0.done } }
    private var done: [TaskItem] { items.filter { $0.done } }

    var body: some View {
        List {
            if items.isEmpty {
                emptyState
            } else {
                if !pending.isEmpty {
                    Section {
                        ForEach(pending, id: \.id) { item in
                            TaskRowView(item: item, onToggle: onToggle, onDelete: onDelete)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                        }
                    }
                }

                if !done.isEmpty {
                    Section("Erledigt") {
                        ForEach(done, id: \.id) { item in
                            TaskRowView(item: item, onToggle: onToggle, onDelete: onDelete)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(type.displayName)
        .navigationBarTitleDisplayMode(.large)
        .tint(type.color)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !items.isEmpty {
                    Text("\(pending.count) offen")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var emptyState: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(type.color.opacity(0.3))
                Text("Noch keine \(type.displayName)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Nimm eine Sprachnotiz auf, um Einträge hinzuzufügen.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .listRowBackground(Color.clear)
        }
    }
}
