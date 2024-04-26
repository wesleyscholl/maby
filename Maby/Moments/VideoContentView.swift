import Aespa
import SwiftUI
import PhotosUI

struct VideoContentView: View {
    @Binding var isPresented: Bool
    @State var isRecording = false
    @State var isFront = false
    @State var showSetting = false
    @State var showGallery = false
    @State var captureMode: AssetType = .photo
    @State private var flashMode: AVCaptureDevice.FlashMode = .off

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var viewModel = VideoContentViewModel()
    
    let colorPink = Color(red: 246/255, green: 158/255, blue: 174/255)
    let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)
    let lightPink = Color(red: 254/255, green: 242/255, blue: 242/255)
    let darkColor = Color(red: 78/255, green: 0/255, blue: 25/255)
    
    var body: some View {
        ZStack {
            viewModel.preview
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack(alignment: .center) {
                    // Mode change
                    Picker("Capture Modes", selection: $captureMode) {
                        Text("Photo").tag(AssetType.photo)
                        Text("Video").tag(AssetType.video)
                    }
                    .pickerStyle(.segmented)
                    .cornerRadius(8)
                    .frame(width: 200)
                    .onChange(of: captureMode) { newValue in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    HStack {
                        Button(action: {
                            switch flashMode {
                            case .off:
                                flashMode = .on
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            case .on:
                                flashMode = .auto
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            case .auto:
                                flashMode = .off
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            @unknown default:
                                flashMode = .off
                            }
                        }) {
                            Image(systemName: flashMode == .off ? "bolt.slash.fill" : flashMode == .on ? "bolt.fill" : "bolt.badge.automatic")
                                .resizable()
                                .foregroundColor(colorScheme == .dark ? .white : colorPink)
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(20)
                                .padding(.trailing, 20)
                        }
                        .shadow(color: .white, radius: 1)
                        .contentShape(Rectangle())
                        Spacer()
                        Button(action: {
                            showSetting = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image(systemName: "gear")
                                .resizable()
                                .foregroundColor(colorScheme == .dark ? .white : colorPink)
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .padding(20)
                        .contentShape(Rectangle())
                    }
                }
                Spacer()
                ZStack {
                    HStack {
                        // Album thumbnail + button
//                        Button(action: { showGallery = true }) {
//                            let coverImage = (
//                                captureMode == .video
//                                ? viewModel.videoAlbumCover
//                                : viewModel.photoAlbumCover)
//                            ?? Image("")
//                            roundRectangleShape(with: coverImage, size: 55)
//                        }
//                        .shadow(radius: 5)
//                        .contentShape(Rectangle())
                        Spacer()
                        Spacer()
                        // Position change + button
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.aespaSession.common(.position(position: isFront ? .back : .front))
                            isFront.toggle()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .resizable()
                                .foregroundColor(colorScheme == .dark ? .white : colorPink)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(20)
                                .padding(.trailing, 20)
                        }
                        .contentShape(Rectangle())
                    }
                    
                    // Shutter + button
                    recordingButtonShape(width: 75).onTapGesture {
                        switch captureMode {
                        case .video:
                            if isRecording {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.aespaSession.stopRecording()
                                isRecording = false
                                self.isPresented = false
                            } else {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.aespaSession.startRecording(autoVideoOrientationEnabled: true)
                                isRecording = true
                            }
                        case .photo:
                            viewModel.aespaSession.capturePhoto(autoVideoOrientationEnabled: true)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            self.isPresented = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSetting) {
            SettingView(contentViewModel: viewModel, showSetting: $showSetting)
            .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
        }
        .sheet(isPresented: $showGallery) {
            GalleryView(mediaType: $captureMode, contentViewModel: viewModel)
        }
        .onChange(of: flashMode) { newValue in
            viewModel.aespaSession.photo(.flashMode(mode: newValue))
        }
    }
}

extension VideoContentView {
    @ViewBuilder
    func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .dark ? .white : colorPink, lineWidth: 1)
            )
            .padding(20)
    }
    
    @ViewBuilder
    func recordingButtonShape(width: CGFloat) -> some View {
        ZStack(alignment: .center) {
            if captureMode == .video {
                Circle()
                    .strokeBorder(colorScheme == .dark ? .white : mediumPink, lineWidth: 3)
                    .frame(width: width)
                RoundedRectangle(cornerRadius: isRecording ? 5 : width * 0.425)
                            .fill(.red)
                            .frame(width: isRecording ? width * 0.45 : width * 0.85, height: isRecording ? width * 0.45 : width * 0.85)
                            .animation(.easeInOut)
            } else {
                Circle()
                    .strokeBorder(colorScheme == .dark ? .white : mediumPink, lineWidth: 3)
                    .frame(width: width)
                
                Circle()
                    .fill(colorScheme == .dark ? .white : colorPink)
                    .frame(width: width * 0.85)
            }
        }
        .frame(height: width)
    }
}

enum AssetType {
    case video
    case photo
}
