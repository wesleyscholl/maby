import SwiftUI
import UIKit
import SwiftData
import MabyKit
import Factory

struct SplashView: View {
    @State private var imageOffset: CGFloat = 0
    @State private var textOffset: CGFloat = -200
    @State private var textOffset2: CGFloat = -240
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    let lightpink = Color(red: 255/255, green: 182/255, blue: 193/255)
    let lightblue = Color(red: 173/255, green: 216/255, blue: 230/255)
    @State private var imageScale: CGFloat = 0
    @State private var imageRotation: Double = 0
    let feedbackGenerator = UINotificationFeedbackGenerator()
    @State private var flashOpacity: Double = 0
    @State private var isActive: Bool = false
    @State private var navigationTarget: Int? = nil
    @Injected(Container.container) private var persistentContainer

    var body: some View {
        NavigationStack {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [lightpink, .white]), startPoint: gradientStart, endPoint: gradientEnd)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        gradientStart = UnitPoint(x: 0, y: 0)
                        gradientEnd = UnitPoint(x: 1, y: 0)
                    }
                }
        VStack {
             Image("lilyan")
            .resizable()
            .scaledToFit()
            .cornerRadius(15)
            .frame(width: 200, height: 200)
            .scaleEffect(imageScale)
            .rotation3DEffect(.degrees(imageRotation), axis: (x: 0, y: 1, z: 0))
            .offset(y: imageOffset)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    imageOffset = -20
                }
                withAnimation(Animation.easeInOut(duration: 1.5).delay(1.5).repeatForever(autoreverses: true)) {
                    imageRotation = 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        imageScale = 2.25
                        flashOpacity = 0.5
                    }
                    withAnimation(Animation.easeInOut(duration: 0.2).delay(0.5)) {
                        imageScale = 1
                        flashOpacity = 0
                    }
                }
            }
        HStack {
    Text("Joy")
        .font(.largeTitle)
        .foregroundColor(.black)
        .opacity(75)
        .padding(0)
        .fontWeight(.medium)
        .offset(x: textOffset)
        .onAppear {
            withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 9)) {
                textOffset = 0
            }
        }
                Text("ful")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .opacity(75)
                    .padding(0)
                    .fontWeight(.medium)
                    .offset(x: textOffset2)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(Animation.interpolatingSpring(stiffness: 100, damping: 9)) {
                                textOffset2 = -8
                            }
                        }
                    }
                }
            }
        }
    NavigationLink(destination: ContentView().environment(\.managedObjectContext, persistentContainer.viewContext), isActive: $isActive) {
                    EmptyView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = true
                }
            }
        }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
