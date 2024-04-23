import SwiftUI

struct ParentView: View {
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    @State var degree = 90.0
    let array : [myVal] =  [myVal(val: "0"),
                            myVal(val: "1"),
                            myVal(val: "2"),
                            myVal(val: "3"),
                            myVal(val: "4"),
                            myVal(val: "5"),
                            myVal(val: "6"),
                            myVal(val: "8"),
                            myVal(val: "9"),
                            myVal(val: "10"),
                            myVal(val: "11"),
                            myVal(val: "12"),
                            myVal(val: "13"),
                            myVal(val: "14"),
                            myVal(val: "15"),
                            myVal(val: "16"),
                            myVal(val: "17"),
                            myVal(val: "18"),
                            myVal(val: "19"),
                            myVal(val: "20"),]

    var body: some View {
        ZStack (alignment: .center){
            Color.orange.opacity(0.4).ignoresSafeArea()
                .hueRotation(Angle(degrees: degree))
            WheelView(degree: $degree, array: array, circleSize: screenWidth)
                .shadow(color: .white, radius: 4, x: 0, y: 0)
        }
    }
}
