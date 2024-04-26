import SwiftUI
import AVFoundation

struct SettingView: View {
    @ObservedObject var viewModel: VideoContentViewModel
    @Binding var showSetting: Bool
    @State private var quality: AVCaptureSession.Preset
    @State private var focusMode: AVCaptureDevice.FocusMode
    @State private var isMuted: Bool
    @State private var flashMode: AVCaptureDevice.FlashMode
    
    init(contentViewModel viewModel: VideoContentViewModel, showSetting: Binding<Bool>) {
        self.viewModel = viewModel
        self._showSetting = showSetting
        self._quality = State(initialValue: viewModel.aespaSession.avCaptureSession.sessionPreset)
        self._focusMode = State(initialValue: viewModel.aespaSession.currentFocusMode ?? .continuousAutoFocus)
        self._isMuted = State(initialValue: viewModel.aespaSession.isMuted)
        self._flashMode = State(initialValue: viewModel.aespaSession.currentSetting.flashMode)
    }
    
    var body: some View {
        List {
            Section(header: Text("Common")) {
                Picker("Quality", selection: $quality) {
                    Text("Low").tag(AVCaptureSession.Preset.low)
                    Text("Medium").tag(AVCaptureSession.Preset.medium)
                    Text("High").tag(AVCaptureSession.Preset.high)
                }
                .modifier(TitledPicker(title: "Asset quality"))
                .onChange(of: quality) { newValue in
                    viewModel.aespaSession.common(.quality(preset: newValue))
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                Picker("Focus", selection: $focusMode) {
                    Text("Auto").tag(AVCaptureDevice.FocusMode.autoFocus)
                    Text("Locked").tag(AVCaptureDevice.FocusMode.locked)
                    Text("Continuous").tag(AVCaptureDevice.FocusMode.continuousAutoFocus)
                }
                .modifier(TitledPicker(title: "Focus mode"))
                .onChange(of: focusMode) { newValue in
                    viewModel.aespaSession.common(.focus(mode: newValue))
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            Section(header: Text("Video")) {
                Picker("Mute", selection: $isMuted) {
                    Text("Unmute").tag(false)
                    Text("Mute").tag(true)
                }
                .modifier(TitledPicker(title: "Mute"))
                .onChange(of: isMuted) { newValue in
                    viewModel.aespaSession.video(newValue ? .mute : .unmute)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            Section(header: Text("Photo")) {
                Picker("Flash", selection: $flashMode) {
                    Text("On").tag(AVCaptureDevice.FlashMode.on)
                    Text("Off").tag(AVCaptureDevice.FlashMode.off)
                    Text("Auto").tag(AVCaptureDevice.FlashMode.auto)
                }
                .modifier(TitledPicker(title: "Flash mode"))
                .onChange(of: flashMode) { newValue in
                    viewModel.aespaSession.photo(.flashMode(mode: newValue))
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showSetting = false
                }) {
                    Text("Close")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(PlainButtonStyle())
        }
    }
    
    struct TitledPicker: ViewModifier {
        let title: String
        func body(content: Content) -> some View {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
                
                content
                    .pickerStyle(.segmented)
                    .frame(height: 40)
            }
        }
    }
}
