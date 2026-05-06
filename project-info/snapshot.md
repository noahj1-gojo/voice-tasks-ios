# Snapshot — Voice Tasks iOS
_Dieses File immer zuerst lesen. Nach jeder Änderung aktualisieren._

## Aktueller Stand (2026-05-05)
- App läuft auf echtem iPhone (iOS 17+)
- Xcode Projekt manuell erstellt (kein SPM, kein CocoaPods)
- Bundle ID: `de.noahj1.voicetasks`
- GitHub: https://github.com/noahj1-gojo/voice-tasks-ios

## Stack
- **UI:** SwiftUI
- **Persistenz:** SwiftData (`@Model`, `@Query`)
- **Spracherkennung:** Apple `SFSpeechRecognizer` + `AVAudioEngine` (on-device)
- **KI:** Mistral API direkt vom iPhone (`mistral-small-latest`)
- **API Key:** UserDefaults (`mistral_api_key`) — kein Backend nötig
- **Min. iOS:** 17.0

## Features
- Mic-Button → Aufnahme → Apple Speech Transkription → Mistral Kategorisierung
- 4 Kategorien: Todos, Termine, Ziele, Reminders (2×2 Grid)
- Karte antippen → Detailansicht (offen/erledigt getrennt)
- Swipe-to-delete, Toggle done/undone
- Dark/Light Mode automatisch (iOS System)
- Simulator-Fallback: Textfeld statt Mic-Button

## Projektstruktur
```
VoiceTasks/
├── VoiceTasksApp.swift          # App entry, SwiftData Container
├── ContentView.swift            # Hauptview, Orchestrierung
├── Models/
│   └── TaskItem.swift           # @Model + TaskType Enum
├── Services/
│   ├── SpeechService.swift      # AVAudioEngine + SFSpeechRecognizer
│   └── MistralService.swift     # Mistral REST API
├── Views/
│   ├── TaskBoardView.swift      # 2×2 LazyVGrid
│   ├── CategoryCardView.swift   # Karte + TaskRowView
│   ├── CategoryDetailView.swift # Vollbild-Detailansicht
│   ├── RecordButtonView.swift   # Animierter Mic-Button
│   └── SettingsView.swift       # API Key Eingabe
└── Extensions/
    └── Color+Hex.swift          # Hex-Color Support
```

## Letzte Änderungen (2026-05-06)
- App Icon ersetzt: IMG_5406 (Schallwelle weiß auf Schwarz, 1024×1024 PNG)
- RecordButton: alle Animationen entfernt, Button ist jetzt vollständig statisch
- Header Banner: fixiert oben (außerhalb ScrollView im ZStack), 200pt — Inhalt scrollt mit `Color(.systemBackground)` Background drüber; Nav Bar transparent, Gear-Button weiß
- Jitter-Fix: `.animation(nil, value: speech.isRecording)` auf TaskBoardView — Topic-Karten bewegen sich nicht mehr beim Record-Start
- Nav bar: nur noch Zahnrad-Button, kein Titel

## Änderungen (2026-05-05)
- Komplettes Projekt von Grund auf erstellt (Swift/SwiftUI)
- Manuelles Xcode-Projekt ohne Wizard (project.pbxproj von Hand)
- Bundle ID auf `de.noahj1.voicetasks` geändert (com.voicetasks.app war vergeben)
- Simulator-Textfeld-Fallback eingebaut
- Kategorie-Detailansicht mit offen/erledigt Trennung
- GitHub Repo erstellt und gepusht

## Offene Punkte
- [ ] Mistral → Claude wechseln (Anthropic API Key fehlt noch)
- [ ] iCloud Sync (SwiftData CloudKit)
- [ ] Siri Shortcuts / App Intents
- [ ] Push Notifications für Reminders/Termine
- [ ] Widget (Home Screen)
- [ ] App Icon Badge für offene Todos

## Signing
- Team: Noah Jäger (Personal Team) — kostenlose Apple ID
- Automatic Signing aktiv
- Zertifikat läuft nach 7 Tagen ab → dann erneut in Xcode deployen
