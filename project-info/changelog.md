# Changelog

## v1.1 — 2026-05-12
- App umbenannt von "Voice Tasks" auf "todos"
- Projekt/Repo umbenannt: VoiceTasks → Todos, voice-tasks-ios → todos-ios
- Bundle ID: `de.noahj1.voicetasks` → `de.noahj1.todos`
- Appointments-Kategorie komplett entfernt — alles wird zu Todos
- Mistral-Prompt überarbeitet (date/time optional auf Todos)
- Layout: Card-Block durch flache Liste ersetzt (offen + Erledigt-Sektion)
- Banner-Logo entfernt, durch "todos." Text-Header ersetzt
- Cleanup-Job beim App-Start löscht alte type≠"todos" Einträge

## v1.0 — 2026-05-05
- Initiales Release
- Komplettes SwiftUI Projekt von Grund auf erstellt
- Sprachaufnahme + Apple Speech Recognition
- Mistral AI Kategorisierung (4 Kategorien)
- 2×2 Grid mit Kategorie-Karten
- Detailansicht pro Kategorie (offen/erledigt)
- Dark/Light Mode
- App Icon: Glühbirne mit Sonne
- Simulator-Textfeld-Fallback
- GitHub Repo: https://github.com/noahj1-gojo/voice-tasks-ios (jetzt todos-ios)
