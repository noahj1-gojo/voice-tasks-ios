import SwiftUI
import SwiftData

@MainActor
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var items: [TaskItem]

    @StateObject private var speech = SpeechService()
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showSettings = false
    @State private var showPermissionAlert = false
    @State private var selectedType: TaskType? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Fixed banner — never scrolls
                VStack {
                    Image("HeaderBanner")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 174)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    Spacer()
                }

                // Scrollable content slides over the banner
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 180)

                        VStack(spacing: 0) {
                            if speech.isRecording && !speech.transcript.isEmpty {
                                TranscriptBubble(text: speech.transcript)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)
                                    .padding(.bottom, 8)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            TaskBoardView(
                                items: items,
                                onToggle: toggleItem,
                                onDelete: deleteItem,
                                onSelectType: { selectedType = $0 }
                            )
                                .padding(.top, 12)
                                .padding(.bottom, 110)
                                .animation(nil, value: speech.isRecording)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                    }
                }
                .ignoresSafeArea(edges: .top)

                if let error = errorMessage {
                    ErrorBanner(message: error) { errorMessage = nil }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                bottomBar
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(item: $selectedType) { type in
                CategoryDetailView(type: type, onToggle: toggleItem, onDelete: deleteItem)
            }
            .alert("Berechtigung erforderlich", isPresented: $showPermissionAlert) {
                Button("Einstellungen öffnen") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Bitte Mikrofon- und Spracherkennungszugriff in den Einstellungen erlauben.")
            }
        }
        .animation(.easeInOut(duration: 0.28), value: speech.isRecording)
        .animation(.easeInOut(duration: 0.28), value: errorMessage)
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            #if targetEnvironment(simulator)
            simulatorInput
            #else
            HStack {
                Spacer()
                RecordButtonView(
                    isRecording: speech.isRecording,
                    isProcessing: isProcessing,
                    action: handleRecordTap
                )
                Spacer()
            }
            .padding(.vertical, 14)
            #endif
        }
        .background(.regularMaterial)
    }

    @State private var simulatorText = ""

    private var simulatorInput: some View {
        HStack(spacing: 10) {
            TextField("Text eingeben (Simulator-Modus)...", text: $simulatorText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .disabled(isProcessing)

            Button {
                let text = simulatorText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                simulatorText = ""
                Task { await analyzeTranscript(text) }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "007AFF"))
                        .frame(width: 36, height: 36)
                    if isProcessing {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .disabled(simulatorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func handleRecordTap() {
        if speech.isRecording {
            let captured = speech.transcript
            speech.stopRecording()
            if !captured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Task { await analyzeTranscript(captured) }
            }
        } else {
            Task {
                let granted = await speech.requestPermissions()
                if granted {
                    speech.startRecording()
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }

    private func analyzeTranscript(_ transcript: String) async {
        isProcessing = true
        errorMessage = nil
        do {
            let newItems = try await MistralService.shared.analyze(transcript: transcript)
            for item in newItems {
                modelContext.insert(item)
            }
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }

    private func toggleItem(_ item: TaskItem) {
        item.done.toggle()
        try? modelContext.save()
    }

    private func deleteItem(_ item: TaskItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

// MARK: - Helper views

struct TranscriptBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "waveform")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: "007AFF"))
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.primary)
                .lineLimit(4)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .lineLimit(3)
            Spacer(minLength: 0)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}
