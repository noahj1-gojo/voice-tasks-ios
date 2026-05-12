import SwiftUI
import SwiftData

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
        type: String = "todos",
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
}
