# todos iOS — Vollständige Dokumentation

## Übersicht
Native iPhone App, die Sprachnotizen aufnimmt, per Apple Speech Recognition transkribiert und via Mistral KI in eine Todo-Liste umwandelt. Komplett offline-fähig (Transkription on-device), nur die KI-Analyse braucht Internet.

---

## Tech Stack

| Komponente | Technologie | Details |
|---|---|---|
| UI Framework | SwiftUI | iOS 17+ Features (NavigationStack, @Query) |
| Datenbank | SwiftData | Lokal, kein iCloud (noch) |
| Sprachaufnahme | AVAudioEngine | Echtzeit-Audio-Buffer |
| Transkription | SFSpeechRecognizer | Apple on-device |
| KI | Mistral API | `mistral-small-latest`, direkter REST Call |
| Persistenz API Key | UserDefaults | Lokal gespeichert |

---

## Architektur

### Datenmodell (`Models/TaskItem.swift`)
```swift
@Model final class TaskItem {
    var id: UUID
    var type: String        // immer "todos" (Feld bleibt für SwiftData-Stabilität)
    var title: String
    var taskDescription: String?
    var date: String?       // "YYYY-MM-DD" oder nil
    var time: String?       // "HH:MM" oder nil
    var done: Bool
    var createdAt: Date
}
```

### Services

**SpeechService** (`Services/SpeechService.swift`)
- `@MainActor ObservableObject`
- `requestPermissions()` — fragt Mikrofon + Speech Recognition Berechtigungen
- `startRecording()` — startet AVAudioEngine, installiert Tap, startet SFSpeechRecognizer Task
- `stopRecording()` — beendet Engine, published fertiges Transkript
- Partielle Ergebnisse werden live in `@Published var transcript` geschrieben

**MistralService** (`Services/MistralService.swift`)
- `@MainActor ObservableObject`, Singleton (`shared`)
- API Key via `@Published var apiKey` → automatisch in UserDefaults gespeichert
- `analyze(transcript:)` — async, wirft `MistralError`
- Sendet Transcript an `mistral-small-latest` mit JSON-Response-Format
- Parsed Response → Array von `TaskItem` Objekten

### Views

**ContentView** — Hauptorchestrator
- `@Query` für SwiftData Items (sortiert nach createdAt desc)
- `@StateObject private var speech = SpeechService()`
- Steuert Recording-Flow, Analyse, Error-Handling
- `#if targetEnvironment(simulator)` → Textfeld statt Mic-Button
- Header: schlichter "todos." Text

**TaskBoardView** — Flache Liste aller Todos
- Offene Items oben
- "Erledigt" Sektion unten (mit Strikethrough)
- Empty State

**TaskRowView** (in `Views/CategoryCardView.swift`)
- Toggle-Button (Kreis → Häkchen), Title, optionale Description, optional Datum/Uhrzeit
- Swipe-to-delete

**RecordButtonView** — Statischer Button
- Blau (Idle) → Rot (Recording) → Spinner (Processing)

---

## Mistral API Integration

### Prompt
```
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
```

### API Call
- Endpoint: `https://api.mistral.ai/v1/chat/completions`
- Model: `mistral-small-latest`
- response_format: `{ type: "json_object" }`
- Temperature: `0.2`

---

## Xcode Projekt Setup

### Manuelle Projektstruktur
Das Projekt wurde ohne Xcode Wizard erstellt — die `project.pbxproj` ist handgeschrieben mit eigenen 24-char Hex UUIDs (Schema: `AA00000000000000000000XX`).

### Build Settings (Target)
```
IPHONEOS_DEPLOYMENT_TARGET = 17.0
SWIFT_VERSION = 5.0
PRODUCT_BUNDLE_IDENTIFIER = de.noahj1.todos
TARGETED_DEVICE_FAMILY = 1  (iPhone only)
CODE_SIGN_STYLE = Automatic
GENERATE_INFOPLIST_FILE = NO  (eigene Info.plist)
```

### Info.plist Keys
- `NSMicrophoneUsageDescription` — Pflicht für AVAudioSession
- `NSSpeechRecognitionUsageDescription` — Pflicht für SFSpeechRecognizer
- `CFBundleIdentifier` — `de.noahj1.todos`
- `CFBundleDisplayName` — `todos`

---

## Farben
| Element | Farbe | Hex |
|---|---|---|
| Accent | Apple Blue | #007AFF |

Dark Mode: `#1C1C1E` Cards, `#000000` Background (OLED)
Light Mode: `#FFFFFF` Cards, `#F2F2F7` Background

---

## Deployment

### Auf echtem iPhone (kostenlose Apple ID)
1. iPhone per USB verbinden
2. iPhone entsperren → "Diesem Computer vertrauen" → Passcode eingeben
3. Xcode → Signing & Capabilities → Team: "Noah Jäger (Personal Team)"
4. iPhone als Ziel auswählen → ⌘R
5. Ersten Start: iPhone → Einstellungen → Datenschutz & Sicherheit → Entwickler-App → Vertrauen
6. **Wichtig:** Zertifikat läuft nach 7 Tagen ab → erneut ⌘R

### Simulator
- Mic-Button durch Textfeld ersetzt (`#if targetEnvironment(simulator)`)
- Zuerst API Key in Settings eintragen, dann Text eingeben + Pfeil

---

## Geplante Features
- **Claude statt Mistral** — Anthropic API Key fehlt noch
- **iCloud Sync** — SwiftData CloudKit Container
- **Siri Shortcuts** — App Intents Framework
- **Push Notifications** — für Items mit Datum/Uhrzeit
- **Home Screen Widget** — offene Todos anzeigen
- **App Icon Badge** — Anzahl offener Todos
