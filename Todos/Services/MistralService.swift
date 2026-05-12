import Foundation

// MARK: - Mistral API types

private struct MistralRequest: Encodable {
    let model: String
    let messages: [Message]
    let response_format: ResponseFormat
    let temperature: Double

    struct Message: Encodable {
        let role: String
        let content: String
    }
    struct ResponseFormat: Encodable {
        let type: String
    }
}

private struct MistralAPIResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
        struct Message: Decodable {
            let content: String
        }
    }
}

private struct ParsedItems: Decodable {
    let todos: [ParsedItem]?

    struct ParsedItem: Decodable {
        let title: String
        let description: String?
        let date: String?
        let time: String?
    }
}

// MARK: - Service

enum MistralError: LocalizedError {
    case missingAPIKey
    case httpError(Int)
    case emptyResponse
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Kein Mistral API Key. Bitte in den Einstellungen eintragen."
        case .httpError(let code):
            return "API-Fehler: HTTP \(code)"
        case .emptyResponse:
            return "Keine Antwort vom KI-Modell."
        case .parseError(let msg):
            return "Antwort konnte nicht gelesen werden: \(msg)"
        }
    }
}

@MainActor
final class MistralService: ObservableObject {
    static let shared = MistralService()

    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "mistral_api_key") }
    }

    private let baseURL = URL(string: "https://api.mistral.ai/v1/chat/completions")!

    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "mistral_api_key") ?? ""
    }

    private let systemPrompt = """
    You are a personal assistant. Extract every actionable item from this voice message transcript and return them as todos.
    Return ONLY valid JSON — no markdown, no explanation, nothing else.

    Everything counts as a todo: tasks, errands, goals, reminders, follow-ups, and appointments.
    If the user mentions a date or time, include it on the todo.

    JSON format:
    {
      "todos": [{ "title": "...", "description": "...", "date": "YYYY-MM-DD or null", "time": "HH:MM or null" }]
    }

    Rules:
    - "title": short, imperative, in the language of the transcript.
    - "description": optional, only if it adds real context — never just rephrase the title.
    - "date" / "time": only set when the user actually said one; otherwise null.

    Transcript:
    """

    func analyze(transcript: String) async throws -> [TaskItem] {
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw MistralError.missingAPIKey
        }

        let body = MistralRequest(
            model: "mistral-small-latest",
            messages: [.init(role: "user", content: systemPrompt + " \"\(transcript)\"")],
            response_format: .init(type: "json_object"),
            temperature: 0.2
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw MistralError.httpError(http.statusCode)
        }

        let apiResponse = try JSONDecoder().decode(MistralAPIResponse.self, from: data)
        guard let content = apiResponse.choices.first?.message.content else {
            throw MistralError.emptyResponse
        }

        guard let contentData = content.data(using: .utf8) else {
            throw MistralError.parseError("Invalid encoding")
        }

        let parsed: ParsedItems
        do {
            parsed = try JSONDecoder().decode(ParsedItems.self, from: contentData)
        } catch {
            throw MistralError.parseError(error.localizedDescription)
        }

        var items: [TaskItem] = []
        func add(_ list: [ParsedItems.ParsedItem]?, type: String) {
            list?.forEach { item in
                items.append(TaskItem(
                    type: type,
                    title: item.title,
                    taskDescription: item.description,
                    date: item.date,
                    time: item.time
                ))
            }
        }
        add(parsed.todos, type: "todos")
        return items
    }
}
