import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let isProcessing: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.25), lineWidth: 2)
                        .frame(width: 84, height: 84)
                        .scaleEffect(pulse ? 1.3 : 1.0)
                        .opacity(pulse ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: pulse
                        )
                }

                Circle()
                    .fill(buttonColor)
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: buttonColor.opacity(0.45),
                        radius: 12, x: 0, y: 4
                    )

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .scaleEffect(isRecording ? 1.05 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isRecording)
        .onAppear { pulse = true }
    }

    private var buttonColor: Color {
        if isRecording { return .red }
        return Color(hex: "007AFF")
    }
}
