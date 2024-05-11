//import SwiftUI
//
//struct KeyframeAnimationView: View {
//    
//    let totalDuration = 0.5
//    
//    var body: some View {
//        Image(systemName: "checkmark.circle.fill")
//            .resizable()
//            .foregroundStyle (.orange) .frame(width: 100, height: 100)
//            .keyframeAnimator(initialValue: AnimationProperties(), repeating: true) {
//                content, value in
//                content
//                    .scaleEffect(y: value.verticalStretch, anchor: .bottom)
//                    .offset(y: value.yTranslation)
//            } keyframes: { _ in
//                
//                
//                var body: some View {
//                    content, value in
//                    content
//                        .scaleEffect(y: value.verticalStretch, anchor: .bottom)
//                        .offset(y: value.yTranslation)
//                } keyframes: { _ in
//                    KeyframeTrack(\.verticalStretch) { Spring Keyframe (0.6, duration: totalDuration * 0.15)
//                        CubicKeyframe(1, duration: totalDuration * 0.15)
//                        CubicKeyframe (1.2, duration:totalDuration * 0.4)
//                        CubicKeyframe(1.1, duration:
//                                        totalDuration * 0.15)
//                        SpringKeyframe (1, duration:
//                                            totalDuration * 0.15)
//                    }
//                    KeyframeTrack(\.yTranslation) {
//                        CubicKeyframe (0, duration:
//                                        totalDuration * 0.1)
//                        CubicKeyframe (-100, duration:
//                                            totalDuration * 0.3)
//                        CubicKeyframe (-100, duration:
//                                            totalDuration * 0.3)
//                        CubicKeyframe(0, duration:
//                                        totalDuration * 0.3)
//                    }
//                }
//            }
//    }
//}
