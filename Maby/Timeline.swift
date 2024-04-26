import SwiftUI

struct TimelineView: View {
    @State var rotation: Double = 0
    let images = ["baby-girl-1", "lilyan", "baby-girl-1", "lilyan","baby-girl-1", "lilyan","baby-girl-1", "lilyan","baby-girl-1", "lilyan","baby-girl-1", "lilyan"]
    
    var body: some View {
        WheelImageView(images: images, rotation: $rotation)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width) // Adjust size as needed
    }
}

struct WheelImageView: View {
    let images: [String]
    @Binding var rotation: Double
    @State var selectedImage: String? = nil
    let wheelSize: CGFloat = UIScreen.main.bounds.width // Your desired wheel size
    
    var body: some View {
        ZStack {
            if let selectedImage = selectedImage {
                Image(selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: wheelSize/3, height: wheelSize/3)
            }
            EllipticalGradientShape()
                .stroke(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom), lineWidth: wheelSize/6)
                .frame(width: wheelSize/2, height: wheelSize/2)
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: wheelSize/6, height: wheelSize/6)
                    .offset(y: -wheelSize/1.2/2)
                    .rotationEffect(.degrees(Double(index) * (360/Double(images.count))))
                    .onTapGesture {
                        selectedImage = images[index]
                    }
            }
        }
        .rotationEffect(.degrees(rotation))
        .gesture(DragGesture()
            .onChanged { gesture in
                let vector = CGVector(dx: gesture.location.x, dy: gesture.location.y)
                let angle = atan2(vector.dy - (wheelSize / 2), vector.dx - (wheelSize / 2))
                rotation = angle * (180 / .pi)
            }
            .onEnded { _ in
                rotation = (round(rotation / (360/Double(images.count)))) * (360/Double(images.count))
            }
        )
    }
}

struct EllipticalGradientShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}
