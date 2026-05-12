import SwiftUI

// MARK: - Button color scheme

enum ButtonColor: String, CaseIterable {
    case blue   = "007AFF"
    case purple = "BF5AF2"
    case green  = "34C759"
    case pink   = "FF375F"
    case orange = "FF9F0A"
    case glass  = "glass"

    var label: String {
        switch self {
        case .blue:   "Blau"
        case .purple: "Lila"
        case .green:  "Grün"
        case .pink:   "Pink"
        case .orange: "Orange"
        case .glass:  "Glas"
        }
    }

    var color: Color {
        switch self {
        case .glass: .white
        default: Color(hex: rawValue)
        }
    }

    var swatchStroke: Color {
        self == .glass ? .secondary.opacity(0.4) : .clear
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject private var mistral = MistralService.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("buttonColorKey") private var buttonColorKey = ButtonColor.blue.rawValue
    @State private var showKey = false

    private var selectedColor: ButtonColor {
        ButtonColor(rawValue: buttonColorKey) ?? .blue
    }

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

                Section("Button-Design") {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 0) {
                            ForEach(ButtonColor.allCases, id: \.rawValue) { scheme in
                                colorSwatch(scheme)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 4)

                        HStack(spacing: 0) {
                            Spacer()
                            buttonPreview(recording: false)
                            Spacer()
                            buttonPreview(recording: true)
                            Spacer()
                        }
                    }
                }

                Section("Info") {
                    LabeledContent("KI-Modell", value: "mistral-small-latest")
                    LabeledContent("Transkription", value: "Apple Speech (On-Device)")
                    LabeledContent("Version", value: "1.1")
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

    private func colorSwatch(_ scheme: ButtonColor) -> some View {
        let isSelected = selectedColor == scheme
        return Button {
            buttonColorKey = scheme.rawValue
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(scheme == .glass ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(scheme.color))
                        .frame(width: 36, height: 36)
                    Circle()
                        .strokeBorder(scheme.swatchStroke, lineWidth: 1)
                        .frame(width: 36, height: 36)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(scheme == .glass ? Color.primary : .white)
                    }
                }
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? Color.primary : .clear, lineWidth: 2.5)
                        .frame(width: 42, height: 42)
                )
                Text(scheme.label)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: selectedColor)
    }

    private func buttonPreview(recording: Bool) -> some View {
        ZStack {
            Circle().fill(.ultraThinMaterial)
            Circle().fill((recording ? Color.red : selectedColor.color).opacity(0.22))
            Circle().strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.65), .white.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            Image(systemName: recording ? "stop.fill" : "mic.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(recording ? Color.red : selectedColor.color)
        }
        .frame(width: 36, height: 36)
        .shadow(color: (recording ? Color.red : selectedColor.color).opacity(0.4), radius: 8, x: 0, y: 3)
    }
}
