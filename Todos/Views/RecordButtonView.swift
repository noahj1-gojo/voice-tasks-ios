import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let isProcessing: Bool
    let tintColor: Color
    let action: () -> Void

    private var activeTint: Color { isRecording ? .red : tintColor }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Liquid glass base
                Circle()
                    .fill(.ultraThinMaterial)

                // Color tint layer
                Circle()
                    .fill(activeTint.opacity(0.22))

                // Specular rim
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.65), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

                // Inner highlight (top arc glow)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.25), .clear],
                            center: .init(x: 0.35, y: 0.2),
                            startRadius: 0,
                            endRadius: 28
                        )
                    )

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primary)
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(activeTint)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .frame(width: 64, height: 64)
            .shadow(color: activeTint.opacity(0.4), radius: 16, x: 0, y: 6)
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
    }
}
