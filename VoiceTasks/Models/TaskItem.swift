import SwiftUI
import SwiftData

enum TaskType: String, Codable, CaseIterable {
    case todos, appointments, goals, reminders

    var displayName: String {
        switch self {
        case .todos: "Todos"
        case .appointments: "Termine"
        case .goals: "Ziele"
        case .reminders: "Reminders"
        }
    }

    var color: Color {
        switch self {
        case .todos: Color(hex: "007AFF")
        case .appointments: Color(hex: "34C759")
        case .goals: Color(hex: "FF9500")
        case .reminders: Color(hex: "FF3B30")
        }
    }

    var icon: String {
        switch self {
        case .todos: "checkmark.circle"
        case .appointments: "calendar"
        case .goals: "star"
        case .reminders: "bell"
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
