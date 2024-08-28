import SwiftUI

struct VoiceTranscriptionButton: View {
    @ObservedObject private var transcriptionManager = VoiceTranscriptionManager.shared
    @Binding var notes: String

    var body: some View {
        Button(action: {
            if transcriptionManager.isRecording {
                print("BEFORE NOTES:", notes)
                transcriptionManager.stopRecording()
                print("NOTES:", notes)
            } else {
                notes = ""
                transcriptionManager.startTranscribing { transcribedText in
                    if !transcribedText.isEmpty {
                        self.notes += (self.notes.isEmpty ? "" : " ") + transcribedText
                    }
                }
            }
        }) {
            Image(systemName: transcriptionManager.isRecording ? "mic.circle.fill" : "mic.fill")
                .foregroundColor(transcriptionManager.isRecording ? Color.red : Color("ButtonColor"))
                .padding(10)
                .background(transcriptionManager.isRecording ? Color.red.opacity(0.2) : Color.clear)
                .clipShape(Circle())
                .shadow(radius: 5)
                .font(.title2)
        }
    }
}
