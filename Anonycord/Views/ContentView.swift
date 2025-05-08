import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingSettings = false
    @State private var isRecordingVideo = false
    @State private var isRecordingAudio = false
    @State private var longPressProgress: CGFloat = 0
    @State private var isLongPressing: Bool = false
    @StateObject private var mediaRecorder = MediaRecorder()
    
    private var recordingStopGesture: some Gesture {
        LongPressGesture(minimumDuration: appSettings.longPressStopDuration)
            .onEnded { _ in
                if isRecordingVideo {
                    toggleVideoRecording()
                }
                if isRecordingAudio {
                    toggleAudioRecording()
                }
            }
            .simultaneously(with: DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isLongPressing {
                        withAnimation {
                            longPressProgress = min(1.0, longPressProgress + 0.1)
                        }
                    }
                }
                .onEnded { _ in
                    longPressProgress = 0
                    isLongPressing = false
                })
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                if !isRecordingAudio && !isRecordingVideo {
                    Image(uiImage: Bundle.main.icon!)
                        .cornerRadius(10)
                        .transition(.scale)
                    Text("Anonycord")
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold))
                        .transition(.scale)
                }
                Spacer()
                
                if !appSettings.hideAll || (!isRecordingAudio && !isRecordingVideo) {
                    HStack {
                        if !isRecordingAudio {
                            RecordButton(isRecording: $isRecordingVideo, action: toggleVideoRecording, icon: "video.circle.fill")
                                .transition(.scale)
                            if !isRecordingVideo {
                                Spacer()
                            }
                        }
                        
                        if !isRecordingVideo {
                            RecordButton(isRecording: $isRecordingAudio, action: toggleAudioRecording, icon: "mic.circle.fill")
                                .transition(.scale)
                            if !isRecordingAudio {
                                Spacer()
                            }
                        }
                        
                        if !isRecordingVideo && !isRecordingAudio {
                            ControlButton(action: takePhoto, icon: "camera.circle.fill")
                                .transition(.scale)
                            Spacer()
                            ControlButton(action: { showingSettings.toggle() }, icon: "gear.circle.fill")
                                .sheet(isPresented: $showingSettings) {
                                    SettingsView(mediaRecorder: mediaRecorder)
                                }
                                .transition(.scale)
                        }
                    }
                    .padding()
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .cornerRadius(30)
                    .padding()
                }
            }
            
            // Recording overlay
            if isRecordingVideo || isRecordingAudio {
                Color.black
                    .opacity(appSettings.autoDimming ? appSettings.dimmingIntensity : 0)
                    .edgesIgnoringSafeArea(.all)
                    .gesture(appSettings.requireLongPressToStop ? recordingStopGesture : nil)
                
                if appSettings.requireLongPressToStop {
                    Circle()
                        .trim(from: 0, to: longPressProgress)
                        .stroke(Color.red, lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                }
            }
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        mediaRecorder.requestPermissions()
        mediaRecorder.setupCaptureSession()
    }
    
    private func toggleVideoRecording() {
        if isRecordingVideo {
            mediaRecorder.stopVideoRecording()
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            UIApplication.shared.isIdleTimerDisabled = true
            mediaRecorder.startVideoRecording { url in
                if let url = url {
                    mediaRecorder.saveVideoToLibrary(videoURL: url)
                }
                isRecordingVideo = false
            }
        }
        isRecordingVideo.toggle()
    }
    
    private func toggleAudioRecording() {
        if isRecordingAudio {
            UIApplication.shared.isIdleTimerDisabled = false
            mediaRecorder.stopAudioRecording()
        } else {
            UIApplication.shared.isIdleTimerDisabled = true
            mediaRecorder.startAudioRecording()
        }
        isRecordingAudio.toggle()
    }
    
    private func takePhoto() {
        mediaRecorder.takePhoto()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
    }
}
