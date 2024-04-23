import SwiftUI

struct WheelView: View {
    // Circle Radius
    @State var radius : Double = 150
    // Direction of swipe
    @State var direction = Direction.left
    // index of the number at the bottom of the circle
    @State var chosenIndex = 0
    // degree of circle and hue
    @Binding var degree : Double
//    @State var degree = 90.0

    let array : [myVal]
    let circleSize : Double

    
    func moveWheel() {
        withAnimation(.spring()) {
            if direction == .left {
                degree += Double(360/array.count)
                if chosenIndex == 0 {
                    chosenIndex = array.count-1
                } else {
                    chosenIndex -= 1
                }
            } else {
                degree -= Double(360/array.count)
                if chosenIndex == array.count-1 {
                    chosenIndex = 0
                } else {
                    chosenIndex += 1
                }
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
    
    var body: some View {
        ZStack {
            let anglePerCount = Double.pi * 2.0 / Double(array.count)
            let drag = DragGesture()
                .onEnded { value in
                    if value.startLocation.y < circleSize / 2 {
            // Top half of the wheel
            if value.startLocation.x < value.location.x + 10 {
                direction = .left
            } else if value.startLocation.x > value.location.x - 10 {
                direction = .right
            }
        } else {
            // Bottom half of the wheel
            if value.startLocation.x > value.location.x + 10 {
                direction = .left
            } else if value.startLocation.x < value.location.x - 10 {
                direction = .right
            }
        }
        moveWheel()
                }
            // MARK: WHEEL STACK - BEGINNING
            ZStack {
                Circle().fill(EllipticalGradient(colors: [.orange,.yellow]))
                    .hueRotation(Angle(degrees: degree))

                ForEach(0 ..< array.count) { index in
                    let angle = (Double(index) + 0.5) * anglePerCount
                    let xOffset = CGFloat(radius * cos(angle))
                    let yOffset = CGFloat(radius * sin(angle))
                    Text("\(array[index].val)")
                        .rotationEffect(Angle(degrees: -degree))
                        .offset(x: xOffset, y: yOffset )
                        .font(Font.system(chosenIndex == index ? .title : .body, design: .monospaced))
                }
                // Draw lines
                ForEach(0 ..< array.count) { index in
                    let angle = Double(index) * anglePerCount
                    let xOffset = CGFloat((circleSize / 2) * cos(angle))
                    let yOffset = CGFloat((circleSize / 2) * sin(angle))
                    Path { path in
                        path.move(to: CGPoint(x: circleSize / 2, y: circleSize / 2))
                        path.addLine(to: CGPoint(x: circleSize / 2 + xOffset, y: circleSize / 2 + yOffset))
                    }
                    .stroke(Color.white, lineWidth: 1)
                }
            }
            .rotationEffect(Angle(degrees: degree - Double(chosenIndex) * (360.0 / Double(array.count))))
            .gesture(drag)
            .onAppear() {
                radius = circleSize/2 - 30 // 30 is for padding
            }
            // MARK: WHEEL STACK - END
        }
        .frame(width: circleSize, height: circleSize)
    }
}
