import SwiftUI

struct SettingsView: View {
    @ObservedObject private var mistral = MistralService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showKey {
                            TextField("API Key", text: $mistral.apiKey)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField("API Key eingeben", text: $mistral.apiKey)
                        }
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    if !mistral.apiKey.isEmpty {
                        Label("API Key gesetzt", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 13))
                    }
                } header: {
                    Text("Mistral AI")
                } footer: {
                    Text("API Key unter console.mistral.ai erstellen. Wird lokal auf dem Gerät gespeichert.")
                }

                Section("Info") {
                    LabeledContent("KI-Modell", value: "mistral-small-latest")
                    LabeledContent("Transkription", value: "Apple Speech (On-Device)")
                    LabeledContent("Version", value: "1.0")
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
