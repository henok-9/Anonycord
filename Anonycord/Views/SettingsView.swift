import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.openURL) var openURL
    
    @State private var micSplRateStr: String
    @State private var channelDefStr: String
    @State private var cameraType: String
    @State private var videoQuality: String
    @State private var frameRate: String
    // @State private var exitAtEnd: Bool
    // @State private var infoAtBttm: Bool
    // @State private var hideAll: Bool
    
    @ObservedObject var mediaRecorder: MediaRecorder

    @State private var cameraTypes = ["Wide", "Selfie"]
    private let videoQualities = ["4K", "1080p"]
    private let frameRates = ["30 FPS", "60 FPS"]
    
    // init(mediaRecorder: MediaRecorder) {
    //     self.mediaRecorder = mediaRecorder
    //     _micSplRateStr = State(initialValue: String(AppSettings().micSampleRate))
    //     _channelDefStr = State(initialValue: String(AppSettings().channelDef))
    //     _cameraType = State(initialValue: AppSettings().cameraType)
    //     _videoQuality = State(initialValue: AppSettings().videoQuality)
    //     _exitAtEnd = State(initialValue: AppSettings().crashAtEnd)
    //     _infoAtBttm = State(initialValue: AppSettings().showSettingsAtBttm)
    //     _hideAll = State(initialValue: AppSettings().hideAll)
    // }
     init(mediaRecorder: MediaRecorder) {
        self.mediaRecorder = mediaRecorder
        _micSplRateStr = State(initialValue: String(AppSettings().micSampleRate))
        _channelDefStr = State(initialValue: String(AppSettings().channelDef))
        _cameraType = State(initialValue: AppSettings().cameraType)
        _videoQuality = State(initialValue: AppSettings().videoQuality)
        _frameRate = State(initialValue: AppSettings().videoFrameRate == 60 ? "60 FPS" : "30 FPS")
    }

var body: some View {
        NavigationView {
            List {
                Section(header: Label("Stealth Features", systemImage: "eye.slash"), footer: Text("Configure stealth recording options")) {
                    Toggle("Auto Screen Dimming", isOn: $appSettings.autoDimming)
                    
                    if appSettings.autoDimming {
                        VStack {
                            Text("Dimming Intensity: \(Int(appSettings.dimmingIntensity * 100))%")
                            Slider(value: $appSettings.dimmingIntensity, in: 0.1...0.9)
                        }
                    }
                    
                    Toggle("Require Long Press to Stop", isOn: $appSettings.requireLongPressToStop)
                    
                    if appSettings.requireLongPressToStop {
                        VStack {
                            Text("Long Press Duration: \(String(format: "%.1f", appSettings.longPressStopDuration))s")
                            Slider(value: $appSettings.longPressStopDuration, in: 1.0...5.0, step: 0.5)
                        }
                    }
                    
                    Toggle("Hide All Controls While Recording", isOn: $appSettings.hideAll)
                        .onChange(of: appSettings.hideAll) { newValue in
                            if newValue {
                                UIApplication.shared.confirmAlert(
                                    title: "Instructions",
                                    body: "To stop recording with this option enabled, use long press anywhere on the screen.",
                                    onOK: {},
                                    noCancel: true
                                )
                            }
                        }
                }
                Section(header: Label("Audio Recording", systemImage: "mic"), footer: Text("Settings for audio recording. Those settings also applies to video recording.")) {
                    Picker("Channels", selection: $channelDefStr) {
                        ForEach(channelsMapping.keys.sorted(), id: \.self) { abbreviation in
                            Text(channelsMapping[abbreviation] ?? abbreviation)
                                .tag(abbreviation)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: channelDefStr) { newValue in
                        appSettings.channelDef = Int(channelDefStr) ?? 1
                    }
                    HStack(spacing: 0) {
                        Text("Sample Rate")
                        Spacer()
                        TextField("44100", text: $micSplRateStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: micSplRateStr) { newValue in
                                micSplRateStr = newValue
                            }
                            .focused($isTextFieldFocused)
                        Text("Hz")
                    }
                    Button("Confirm Sample Rate") {
                        isTextFieldFocused = false
                        appSettings.micSampleRate = Int(micSplRateStr) ?? 44100
                        micSplRateStr = String(appSettings.micSampleRate)
                    }
                    Button("Reset Sample Rate") {
                        isTextFieldFocused = false
                        appSettings.micSampleRate = 44100
                        micSplRateStr = String(appSettings.micSampleRate)
                    }
                }
                Section(header: Label("Video Recording", systemImage: "video"), footer: Text("Options for video recording. Camera Type will also apply to photo settings.")) {
                    Picker("Video quality", selection: $videoQuality) {
                        ForEach(videoQualities, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: videoQuality) { newValue in
                        appSettings.videoQuality = videoQuality
                        DispatchQueue.main.async {
                            mediaRecorder.reconfigureCaptureSession()
                        }
                    }
                    
                    if videoQuality == "4K" {
                        Picker("Frame Rate", selection: $frameRate) {
                            ForEach(frameRates, id: \.self) { rate in
                                Text(rate).tag(rate)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: frameRate) { newValue in
                            appSettings.videoFrameRate = newValue == "60 FPS" ? 60 : 30
                            DispatchQueue.main.async {
                                mediaRecorder.reconfigureCaptureSession()
                            }
                        }
                    }
                    Picker("Camera Type", selection: $cameraType) {
                        ForEach(cameraTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: cameraType) { newValue in
                        appSettings.cameraType = cameraType
                        DispatchQueue.main.async {
                            mediaRecorder.reconfigureCaptureSession()
                        }
                    }
                    .onAppear {
                        if mediaRecorder.hasUltraWideCamera() {
                            cameraTypes.append("UltraWide")
                        }
                    }
                }
                Section(header: Label("Old Settings", systemImage: "eyedropper"), footer: Text("Other settings inspired from the original Anonycord (1.x). Those settings aren't recommended. Crash upon saving only applies to photo and video recording.")) {
                    Toggle(isOn: $exitAtEnd) {
                        Text("Crash upon saving")
                    }
                    .onChange(of: exitAtEnd) { newValue in
                        appSettings.crashAtEnd = exitAtEnd
                    }
                    Toggle(isOn: $hideAll) {
                        Text("Hide All Controls While Recording")
                    }
                    .onChange(of: hideAll) { newValue in
                        if newValue {
                            UIApplication.shared.confirmAlert(title:"Instructions", body: "To stop and save videos with this option enabled, you just have to click anywhere on the screen.", onOK: {}, noCancel: true)
                        }
                        appSettings.hideAll = hideAll
                    }
                }
                Section(header: Label("UI", systemImage: "pencil"), footer: Text("Settings for user interface.")) {
                    Toggle(isOn: $infoAtBttm) {
                        Text("Show Recording Info")
                    }
                    .onChange(of: infoAtBttm) { newValue in
                        appSettings.showSettingsAtBttm = infoAtBttm
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


let channelsMapping: [String: String] = [
    "1": "Mono",
    "2": "Stereo",
]
