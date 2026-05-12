# Snapshot — todos iOS
_Dieses File immer zuerst lesen. Nach jeder Änderung aktualisieren._

## Aktueller Stand (2026-05-12) — neueste Änderungen
- Einstellungs-Gear von oben rechts in die Bottom Bar (rechts neben Mic-Button) verschoben
- Mic-Button: Liquid Glass Design (ultraThinMaterial + Farb-Tint + Rim-Highlight + Glow-Shadow)
- Settings: neue "Button-Design"-Sektion mit 6 Farbschemata (Blau, Lila, Grün, Pink, Orange, Glas)
- Farbe wird in UserDefaults (`buttonColorKey`) gespeichert

## Stand (2026-05-12)
- App heißt "todos", Bundle ID `de.noahj1.todos`
- Projekt-Ordner: `~/todos-ios/`, Xcode-Projekt: `Todos.xcodeproj`
- GitHub: https://github.com/noahj1-gojo/todos-ios
- Nur noch eine Kategorie (Todos), keine Appointments mehr
- Flache Liste (offen oben, Erledigt-Sektion unten), kein Karten-Block, kein Tap-To-Detail mehr
- Header: schlichter "todos." Text statt Banner-Image
- Cleanup-Job beim Start löscht alte type≠"todos" Einträge

## Stack
- **UI:** SwiftUI
- **Persistenz:** SwiftData (`@Model`, `@Query`)
- **Spracherkennung:** Apple `SFSpeechRecognizer` + `AVAudioEngine` (on-device)
- **KI:** Mistral API direkt vom iPhone (`mistral-small-latest`)
- **API Key:** UserDefaults (`mistral_api_key`) — kein Backend nötig
- **Min. iOS:** 17.0

## Features
- Mic-Button → Aufnahme → Apple Speech Transkription → Mistral Extraktion → Todos
- Toggle done/undone, Swipe-to-delete
- Dark/Light Mode automatisch
- Simulator-Fallback: Textfeld statt Mic-Button

## Projektstruktur
```
Todos/
├── TodosApp.swift               # App entry, SwiftData Container, Legacy-Cleanup
├── ContentView.swift            # Hauptview, "todos." Header, Mic-Bar
├── Models/
│   └── TaskItem.swift           # @Model — keine TaskType-Enum mehr
├── Services/
│   ├── SpeechService.swift      # AVAudioEngine + SFSpeechRecognizer
│   └── MistralService.swift     # Mistral REST API, todos-only Prompt
├── Views/
│   ├── TaskBoardView.swift      # Flache Liste, offen + Erledigt
│   ├── CategoryCardView.swift   # Enthält jetzt nur noch TaskRowView (file name historisch)
│   ├── RecordButtonView.swift   # Statischer Mic-Button
│   └── SettingsView.swift       # API Key Eingabe
└── Extensions/
    └── Color+Hex.swift
```

## Letzte Änderungen (2026-05-12)
- App von "Voice Tasks" auf "todos" umbenannt (Display Name, Bundle ID, Repo, Xcode-Projekt, Ordner)
- Appointments-Kategorie raus (Mistral-Prompt, Parser, TaskType-Enum, UI)
- Card-Layout durch flache Liste ersetzt
- Banner-Bild durch "todos." Text-Header ersetzt
- HeaderBanner + NavLogo Assets gelöscht
- CategoryDetailView gelöscht
- Cleanup-Hook beim App-Start (`.task`) entfernt alte Termine
- Layout-Fix vom selben Tag: Cards füllten Screen (jetzt obsolet, da Liste statt Cards)

## Offene Punkte
- [ ] Mistral → Claude wechseln (Anthropic API Key fehlt noch)
- [ ] iCloud Sync (SwiftData CloudKit)
- [ ] Siri Shortcuts / App Intents
- [ ] Push Notifications für Todos mit Datum/Uhrzeit
- [ ] Widget (Home Screen)
- [ ] App Icon Badge für offene Todos
- [ ] Views/CategoryCardView.swift in TaskRowView.swift umbenennen (kosmetisch)

## Signing
- Team: Noah Jäger (Personal Team) — kostenlose Apple ID
- Automatic Signing aktiv
- Zertifikat läuft nach 7 Tagen ab → dann erneut in Xcode deployen
