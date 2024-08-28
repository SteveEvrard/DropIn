import Foundation
import AVFoundation
import Speech

class VoiceTranscriptionManager: NSObject, ObservableObject {
    static let shared = VoiceTranscriptionManager()
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @Published var isRecording = false

    private override init() {
        super.init()
        requestSpeechAuthorization()
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Voice transcription authorized")
                case .denied, .restricted, .notDetermined:
                    print("Voice transcription not authorized")
                    self?.isRecording = false
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    func startTranscribing(completion: @escaping (String) -> Void) {
        guard !isRecording else { return }
        isRecording = true

        request = SFSpeechAudioBufferRecognitionRequest()

        guard let request = request else {
            print("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            isRecording = false
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognition is not available")
            isRecording = false
            return
        }

        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                completion(transcribedText)
            } else if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self.stopRecording() // Stop if there's an error
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Audio engine could not start: \(error.localizedDescription)")
            isRecording = false
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
}
