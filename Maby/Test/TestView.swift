import Factory
import MabyKit
import SwiftUI
import ScalingHeaderScrollView
import SwiftUIIntrospect

struct TestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var progress: CGFloat = 0
    @State private var isloading = false
    @FetchRequest private var babies: FetchedResults<Baby>
    
    init() {
        self._babies = FetchRequest(fetchRequest: allBabies)
    }
    
    private var name: String {
        babies.first?.name ?? ""
    }
    
    private var age: String {
        babies.first?.formattedAge ?? ""
    }
    
    private var gender: Baby.Gender {
        Baby.Gender(rawValue: (babies.first?.gender)!.rawValue) ?? Baby.Gender.girl
    }
    
    private var birthday: Date {
        babies.first?.birthday ?? Date.now
    }
        
        let service = BankingService()

        var body: some View {
            ZStack {
                ScalingHeaderScrollView {
                    ZStack {
                        CardView(progress: progress, name: name, age: age, birthday: birthday, gender: gender)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                } content: {
                    ListItem()
//                    ForEach(service.transactions) { transaction in
//                        TransactionView(transaction: transaction)
//                    }
                }
                .height(min: 220, max: 372)
                .collapseProgress($progress)
                .allowsHeaderCollapse()
            }
//            .background(.white)
            .ignoresSafeArea()
        }
    }

struct ListItem: View {
    let data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"]
        var body: some View {
            VStack(alignment: .center) {
                ForEach(data, id: \.self) { item in
                    Text(item)
                        .background(Color.gray.opacity(0.1))
                        .padding()
                        .cornerRadius(5)
                        .font(.system(size: 20))
                    Divider()
                }
            }
            .padding()
        }
}

struct CardView: View {

    var progress: CGFloat
    var name: String
    var age: String
    var birthday: Date
    var gender: Baby.Gender

    private var isCollapsed: Bool {
        progress > 0.7
    }
    
    private var balance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        
        let number = NSNumber(value: 56112.65)
        let formattedValue = formatter.string(from: number)!
        return "$\(formattedValue)"
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient:
                    Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 230)
                .scaleEffect(y: 0.3 + (1 - progress) * 0.7)
                .mask {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 69 + (1 - progress) * 140)
                }
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .tracking(1.5)
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(name)
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .bold()
                    }
                    Spacer()
                    if !isCollapsed {
                        Image("lilyan")
                            .resizable()
                            .cornerRadius(5)
                            .frame(width: 50, height: 50)
                            .opacity(1 - max(0, min(1, (progress - 0.6) * 10.0)))
                    } else {
                        Image("baby-girl-1")
                            .resizable()
                            .cornerRadius(5)
                            .frame(width: 40, height: 40)
                            .opacity(max(0, min(1, (progress - 0.7) * 4.0)))
                    }
                }
                Spacer()
                Spacer()
                VStack (alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age")
                                .tracking(1.5)
                                .font(.system(size: 8))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Text(age)
                                .bold()
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .tracking(1.5)
                                .foregroundStyle(.white.opacity(0.7))
                                .font(.system(size: 8))
                            
                            Text(gender == .boy ? "Boy" : (gender == .girl ? "Girl" : "Other"))
                                .bold()
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                        }
                    }
                    .bold()
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .opacity(2.0 - progress * 3)
                Spacer()
                VStack(alignment: .leading) {
                        Text("Birthday")
                            .tracking(1.5)
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(birthday.formatted())
                            .bold()
                            .foregroundStyle(.white)
                            .font(.system(size: 15))
                    }
                    
                    Spacer()

                }
                .opacity(1.0 - progress * 5)
            }
            .frame(height: 160)
            .padding(.horizontal, 32)
            .offset(y: progress * 60)
        }
        .padding(20)
        .shadow(color: .gray.opacity(0.6), radius: 16, y: 8)
    }
}

struct TransactionView: View {
    let transaction: BankTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(transaction.iconName)
                .resizable()
                .frame(width: 46, height: 46)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                Text(transaction.category)
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 13))
            }
            .frame(height: 46)
            
            Spacer()
            
            Text("\(String(format: "%.2f", transaction.balance)) $")
                .foregroundColor(transaction.balance > 0 ? .green : .white)
                .bold()
                .font(.system(size: 16))
        }
        .padding(.horizontal, 24)
    }
}

struct CircleButtonStyle: ButtonStyle {

    var imageName: String
    var foreground = Color.black
    var background = Color.white
    var width: CGFloat = 40
    var height: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .fill(background)
            .overlay(Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(foreground)
                        .padding(12))
            .frame(width: width, height: height)
    }
}



//        @ObservedObject private var viewModel = ProfileScreenViewModel()
//        @Environment(\.presentationMode) var presentationMode
//
//        @State var progress: CGFloat = 0
//        
//        private let minHeight = 110.0
//        private let maxHeight = 372.0
//
//        var body: some View {
//            ZStack {
//                ScalingHeaderScrollView {
//                    ZStack {
//                        Color.white.edgesIgnoringSafeArea(.all)
//                        largeHeader(progress: progress)
//                    }
//                } content: {
//                    profilerContentView
//                }
//                .height(min: minHeight, max: maxHeight)
//                .collapseProgress($progress)
//                .allowsHeaderGrowth()
//            }
//            .ignoresSafeArea()
//        }
//
//        private var topButtons: some View {
//            VStack {
//                HStack {
//                    Button("", action: { self.presentationMode.wrappedValue.dismiss() })
//                        .buttonStyle(CircleButtonStyle(imageName: "arrow.backward"))
//                        .padding(.leading, 17)
//                        .padding(.top, 50)
//                    Spacer()
//                    Button("", action: { print("Info") })
//                        .buttonStyle(CircleButtonStyle(imageName: "ellipsis"))
//                        .padding(.trailing, 17)
//                        .padding(.top, 50)
//                }
//                Spacer()
//            }
//            .ignoresSafeArea()
//        }
//
//        private var hireButton: some View {
//            VStack {
//                Spacer()
//                ZStack {
//                    VisualEffectView(effect: UIBlurEffect(style: .regular))
//                        .frame(height: 180)
//                        .padding(.bottom, -100)
//                    HStack {
//                        Button("Hire", action: { print("hire") })
//                            .buttonStyle(HireButtonStyle())
//                            .padding(.horizontal, 15)
//                            .frame(width: 396, height: 60, alignment: .bottom)
//                    }
//                }
//            }
//            .ignoresSafeArea()
//            .padding(.bottom, 40)
//        }
//        
//        private var smallHeader: some View {
//            HStack(spacing: 12.0) {
//                Image(viewModel.avatarImage)
//                    .resizable()
//                    .frame(width: 40.0, height: 40.0)
//                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
//
//                Text(viewModel.userName)
//            }
//        }
//        
//        private func largeHeader(progress: CGFloat) -> some View {
//            ZStack {
//                Image("lilyan")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: maxHeight)
//                    .opacity(1 - progress)
//                
//                VStack {
//                    Spacer()
//                    
//                    HStack(spacing: 4.0) {
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white)
//                        
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white.opacity(0.2))
//                        
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white.opacity(0.2))
//                    }
//                    
//                    ZStack(alignment: .leading) {
//
//                        VisualEffectView(effect: UIBlurEffect(style: .regular))
//                            .mask(Rectangle().cornerRadius(40))
//                            .offset(y: 10.0)
//                            .frame(height: 80.0)
//
//                        RoundedRectangle(cornerRadius: 40.0, style: .circular)
//                            .foregroundColor(.clear)
//                            .background(
//                                LinearGradient(gradient: Gradient(colors: [.white.opacity(0.0), .white]), startPoint: .top, endPoint: .bottom)
//                            )
//
//                        userName
//                            .padding(.leading, 24.0)
//                            .padding(.top, 10.0)
//                            .opacity(1 - max(0, min(1, (progress - 0.75) * 4.0)))
//
//                        smallHeader
//                            .padding(.leading, 85.0)
//                            .opacity(progress)
//                            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
//                    }
//                    .frame(height: 80.0)
//                }
//            }
//        }
//        
//        private var profilerContentView: some View {
//            VStack {
//                HStack {
//                    VStack(alignment: .leading, spacing: 20) {
//                        personalInfo
//                        reviews
//                        skills
//                        description
//                        portfolio
//                        Color.clear.frame(height: 100)
//                    }
//                    .padding(.horizontal, 24)
//                }
//            }
//        }
//
//        private var personalInfo: some View {
//            VStack(alignment: .leading) {
//                profession
//                address
//            }
//        }
//
//        private var userName: some View {
//            Text(viewModel.userName)
//        }
//
//        private var profession: some View {
//            Text(viewModel.profession)
//        }
//
//        private var address: some View {
//            Text(viewModel.address)
//        }
//
//        private var reviews: some View {
//            HStack(alignment: .center , spacing: 8) {
//                Image("Star")
//                    .offset(y: -3)
//                grade
//                reviewCount
//            }
//        }
//
//        private var grade: some View {
//            Text(String(format: "%.1f", viewModel.grade))
//        }
//
//        private var reviewCount: some View {
//            Text("\(viewModel.reviewCount) reviews")
//        }
//
//        private var skills: some View {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Skills")
//                HStack {
//                    ForEach((0 ..< 3)) { col in
//                        skillView(for: viewModel.skils[col])
//                    }
//                }
//                HStack {
//                    ForEach((0 ..< 3)) { col in
//                        skillView(for: viewModel.skils[col + 3])
//                    }
//                }
//            }
//        }
//
//        func skillView(for skill: String) -> some View {
//            Text(skill)
//                .padding(.vertical, 5)
//                .padding(.horizontal, 14)
//                .lineLimit(1)
//                .background(
//                    RoundedRectangle(cornerRadius: 6)
//                        .fill(.blue.opacity(0.08))
//                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.blue))
//                )
//        }
//
//        private var description: some View {
//            Text(viewModel.description)
//        }
//
//        private var portfolio: some View {
//            LazyVGrid(columns: [
//                GridItem(.flexible(minimum: 100)),
//                GridItem(.flexible(minimum: 100)),
//                GridItem(.flexible(minimum: 100))
//            ]) {
//                ForEach(viewModel.portfolio, id: \.self) { imageName in
//                    Image(imageName)
//                        .resizable()
//                        .scaledToFit()
//                }
//            }
//        }
//    }


//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedColor: Color = .green
//    @State var progress: CGFloat = 0
//
//       var body: some View {
//           ZStack {
//               ScalingHeaderScrollView {
//                   ZStack {
//                       BabyCard()
//                   }
//               } content: {
//                   scrollContent
//                       .padding()
//               }
//               .height(min: 110, max: 200)
//               .allowsHeaderGrowth()
//           }
//       }
//       
//       private var scrollContent: some View {
//           LazyVStack {
//               ForEach((0...colorSet.count - 1), id: \.self) { index in
//                   colorRow(index: index)
//               }
//               .background(
//                   Color.gray
//                       .opacity(0.15)
//                       .clipShape(RoundedRectangle(cornerRadius: 8.0))
//               )
//           }
//       }
//       
//       private func colorRow(index: Int) -> some View {
//           HStack {
//               Text(colorSet[index].name)
//               Spacer()
//               colorSet[index]
//                   .clipShape(Circle())
//                   .frame(width: 30.0, height: 30.0)
//           }
//           .padding()
//           .contentShape(Rectangle())
//           .onTapGesture {
//               selectedColor = colorSet[index]
//           }
//       }
//    
//    private func largeHeader(progress: CGFloat) -> some View {
//            ZStack {
//                Image(viewModel.avatarImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: maxHeight)
//                    .opacity(1 - progress)
//                
//                VStack {
//                    Spacer()
//                    
//                    HStack(spacing: 4.0) {
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white)
//                        
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white.opacity(0.2))
//                        
//                        Capsule()
//                            .frame(width: 40.0, height: 3.0)
//                            .foregroundColor(.white.opacity(0.2))
//                    }
//                    
//                    ZStack(alignment: .leading) {
//
//                        VisualEffectView(effect: UIBlurEffect(style: .regular))
//                            .mask(Rectangle().cornerRadius(40, corners: [.topLeft, .topRight]))
//                            .offset(y: 10.0)
//                            .frame(height: 80.0)
//
//                        RoundedRectangle(cornerRadius: 40.0, style: .circular)
//                            .foregroundColor(.clear)
//                            .background(
//                                LinearGradient(gradient: Gradient(colors: [.white.opacity(0.0), .white]), startPoint: .top, endPoint: .bottom)
//                            )
//
//                        userName
//                            .padding(.leading, 24.0)
//                            .padding(.top, 10.0)
//                            .opacity(1 - max(0, min(1, (progress - 0.75) * 4.0)))
//
//                        smallHeader
//                            .padding(.leading, 85.0)
//                            .opacity(progress)
//                            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
//                    }
//                    .frame(height: 80.0)
//                }
//            }
//        }
//        
//   }
//
//
//   let colorSet: [Color] = [.red, .blue, .green, .black, .pink, .purple, .yellow,
//                            .red, .blue, .green, .black, .pink, .purple, .yellow]
//
//   extension Color {
//       var name: String {
//           UIColor(self).accessibilityName
//       }

//struct CircleButtonStyle: ButtonStyle {
//
//    var imageName: String
//    var foreground = Color.black
//    var background = Color.white
//    var width: CGFloat = 40
//    var height: CGFloat = 40
//
//    func makeBody(configuration: Configuration) -> some View {
//        Circle()
//            .fill(background)
//            .overlay(Image(systemName: imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(foreground)
//                        .padding(12))
//            .frame(width: width, height: height)
//    }
//}
//
//struct VisualEffectView: UIViewRepresentable {
//
//    var effect: UIVisualEffect?
//
//    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
//    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
//}
//
//struct HireButtonStyle: ButtonStyle {
//
//    var foreground = Color.white
//
//    func makeBody(configuration: Configuration) -> some View {
//        RoundedRectangle(cornerRadius: 8)
//            .fill(.gray)
//            .overlay(configuration.label.foregroundColor(foreground))
//    }
//}
