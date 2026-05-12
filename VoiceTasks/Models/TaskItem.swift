import SwiftUI
import SwiftData

enum TaskType: String, Codable, CaseIterable {
    case todos, appointments

    var displayName: String {
        switch self {
        case .todos: "Todos"
        case .appointments: "Termine"
        }
    }

    var color: Color {
        switch self {
        case .todos: Color(hex: "007AFF")
        case .appointments: Color(hex: "34C759")
        }
    }

    var icon: String {
        switch self {
        case .todos: "checkmark.circle"
        case .appointments: "calendar"
        }
    }
}

@Model
final class TaskItem {
    var id: UUID
    var type: String
    var title: String
    var taskDescription: String?
    var date: String?
    var time: String?
    var done: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        taskDescription: String? = nil,
        date: String? = nil,
        time: String? = nil,
        done: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.taskDescription = taskDescription
        self.date = date
        self.time = time
        self.done = done
        self.createdAt = createdAt
    }

    var taskType: TaskType {
        TaskType(rawValue: type) ?? .todos
    }
}
