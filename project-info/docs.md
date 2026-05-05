# Voice Tasks iOS — Vollständige Dokumentation

## Übersicht
Native iPhone App, die Sprachnotizen aufnimmt, per Apple Speech Recognition transkribiert und via Mistral KI automatisch in 4 Kategorien einteilt. Komplett offline-fähig (Transkription on-device), nur die KI-Analyse braucht Internet.

---

## Tech Stack

| Komponente | Technologie | Details |
|---|---|---|
| UI Framework | SwiftUI | iOS 17+ Features (NavigationStack, @Query) |
| Datenbank | SwiftData | Lokal, kein iCloud (noch) |
| Sprachaufnahme | AVAudioEngine | Echtzeit-Audio-Buffer |
| Transkription | SFSpeechRecognizer | Apple on-device, kein Datenschutzproblem |
| KI | Mistral API | `mistral-small-latest`, direkter REST Call |
| Persistenz API Key | UserDefaults | Lokal gespeichert |

---

## Architektur

### Datenmodell (`Models/TaskItem.swift`)
```swift
@Model final class TaskItem {
    var id: UUID
    var type: String        // "todos" | "appointments" | "goals" | "reminders"
    var title: String
    var taskDescription: String?
    var date: String?       // "YYYY-MM-DD" oder nil
    var time: String?       // "HH:MM" oder nil
    var done: Bool
    var createdAt: Date
}
```

`TaskType` Enum mit 4 Fällen — enthält displayName, SF Symbol, Apple System Color.

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

**TaskBoardView** — 2×2 LazyVGrid mit `CategoryCardView` pro Typ

**CategoryCardView** — Karte mit:
- Tappbarem Header (chevron.right) → navigiert zur Detailansicht
- Scrollbarer Taskliste (max 220pt Höhe)
- Empty State mit Icon

**CategoryDetailView** — Vollbild-Ansicht einer Kategorie
- Eigener `@Query` mit `#Predicate` gefiltert nach type
- Sections: "Offen" und "Erledigt"
- `ContentUnavailableView` wenn leer

**RecordButtonView** — Animierter Button
- Blau (Idle) → Rot + pulsierender Ring (Recording) → Spinner (Processing)
- `.spring(response: 0.35, dampingFraction: 0.6)` Animation

---

## Mistral API Integration

### Prompt
```
You are a personal assistant. Extract all actionable items from this voice message transcript.
Return ONLY valid JSON — no markdown, no explanation, nothing else.

Categorize into:
- "todos": tasks to do
- "appointments": events at a specific time/date
- "goals": longer-term life goals or aspirations
- "reminders": things to remember or follow up on

JSON format:
{
  "todos": [{ "title": "...", "description": "..." }],
  "appointments": [{ "title": "...", "description": "...", "date": "YYYY-MM-DD or null", "time": "HH:MM or null" }],
  "goals": [{ "title": "...", "description": "..." }],
  "reminders": [{ "title": "...", "description": "...", "date": "YYYY-MM-DD or null", "time": "HH:MM or null" }]
}
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
PRODUCT_BUNDLE_IDENTIFIER = de.noahj1.voicetasks
TARGETED_DEVICE_FAMILY = 1  (iPhone only)
CODE_SIGN_STYLE = Automatic
GENERATE_INFOPLIST_FILE = NO  (eigene Info.plist)
```

### Info.plist Keys
- `NSMicrophoneUsageDescription` — Pflicht für AVAudioSession
- `NSSpeechRecognitionUsageDescription` — Pflicht für SFSpeechRecognizer
- `CFBundleIdentifier` — `de.noahj1.voicetasks`

---

## Farben (Apple System Colors)
| Kategorie | Farbe | Hex |
|---|---|---|
| Todos | Apple Blue | #007AFF |
| Termine | Apple Green | #34C759 |
| Ziele | Apple Orange | #FF9500 |
| Reminders | Apple Red | #FF3B30 |

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
- **Push Notifications** — für Termine und Reminders
- **Home Screen Widget** — offene Todos anzeigen
- **App Icon Badge** — Anzahl offener Todos
