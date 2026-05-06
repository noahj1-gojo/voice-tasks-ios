import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color(hex: "007AFF"))
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: (isRecording ? Color.red : Color(hex: "007AFF")).opacity(0.45),
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
    }
}
