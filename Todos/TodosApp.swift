import SwiftUI
import SwiftData

@main
struct TodosApp: App {
    let container: ModelContainer = {
        let schema = Schema([TaskItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container konnte nicht erstellt werden: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { cleanupLegacyAppointments() }
        }
        .modelContainer(container)
    }

    @MainActor
    private func cleanupLegacyAppointments() {
        let context = container.mainContext
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.type != "todos" })
        guard let stale = try? context.fetch(descriptor), !stale.isEmpty else { return }
        stale.forEach(context.delete)
        try? context.save()
    }
}
