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
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                    }
                } content: {
//                    ListItem()
//                    ForEach(service.transactions) { transaction in
//                        TransactionView(transaction: transaction)
//                    }
                    Text("Feeding").font(.headline).frame(height: 60)
                        Divider().padding(.horizontal)
                        AddEventButton<NursingEvent>(
                            "Add Breast Feeding",
                            icon: "🤱🏻",
                            type: .nursing
                        )
                        Divider().padding(.horizontal)
                        AddEventButton<BreastPumpEvent>(
                            "Add Breast Pumping",
                            icon: "🥛",
                            type: .breastPump
                        )
                        Divider().padding(.horizontal)
                        AddEventButton<BottleFeedEvent>(
                            "Add Bottle Feeding",
                            icon: "🍼",
                            type: .bottle
                        )
                    Divider().padding(.horizontal)
                Text("Hygiene").font(.headline).frame(height: 60)
                        Divider().padding(.horizontal)
                        AddEventButton<DiaperEvent>(
                            "Add Diaper Change",
                            icon: "🚼",
                            type: .diaper
                        )
                        Divider().padding(.horizontal)
                        AddEventButton<BathingEvent>(
                            "Add a Bath or Shower",
                            icon: "🛁",
                            type: .bathing
                        )
                        Divider().padding(.horizontal)
                Text("Health").font(.headline).frame(height: 60)
                        Divider().padding(.horizontal)
                        AddEventButton<SleepEvent>(
                            "Add Sleep or a Nap",
                            icon: "😴",
                            type: .sleep
                        )
                        Divider().padding(.horizontal)
                        AddEventButton<VomitEvent>(
                            "Add Activity",
                            icon: "🪇",
                            type: .activity
                        )
                        Divider().padding(.horizontal)
                        AddEventButton<VomitEvent>(
                            "Add Vomit, Burping or Spit Up",
                            icon: "🤢",
                            type: .vomit
                        )
                        Divider().padding(.horizontal)
                }
                .height(min: 225, max: 370)
                .collapseProgress($progress)
                .allowsHeaderCollapse()
                .allowsHeaderGrowth()
                .padding(.bottom, 75)
                
            }
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
                    if gender == .boy {
                        if !isCollapsed {
                            Image("babyboyz")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 75)
                                .opacity(1 - max(0, min(1, (progress - 0.6) * 10.0)))
                        } else {
                            Image("babyboyz")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .opacity(max(0, min(1, (progress - 0.7) * 4.0)))
                        }
                        } else if gender == .girl {
                            if !isCollapsed {
                                Image("baby-girl-1")
                                    .resizable()
                                    .frame(width: 75, height: 75)
                                    .opacity(1 - max(0, min(1, (progress - 0.6) * 10.0)))
                            } else {
                                Image("baby-girl-1")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .opacity(max(0, min(1, (progress - 0.7) * 4.0)))
                            }
                        } else if gender == .other {
                            if !isCollapsed {
                                Image("baby-g")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75, height: 75)
                                    .opacity(1 - max(0, min(1, (progress - 0.6) * 10.0)))
                            } else {
                                Image("baby-g")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .opacity(max(0, min(1, (progress - 0.7) * 4.0)))
                            }
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
            
            Text(transaction.iconName).font(.system(size: 40))
//                .resizable()
//                .frame(width: 46, height: 46)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                Text(transaction.category)
                    .foregroundColor(.black.opacity(0.4))
                    .font(.system(size: 13))
            }
            .frame(height: 46)
            
            Spacer()
            
            Text("\(String(format: "%.2f", transaction.balance)) $")
                .foregroundColor(transaction.balance > 0 ? .green : .black)
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

private struct AddEventButton<E: Event>: View {
    private let text: LocalizedStringKey
    private let icon: LocalizedStringKey
    private let type: EventType
    // TODO: Consider changing timer tick depending on last time (an event that is already more than an hour old doesn't need to be updated every 30 seconds)
    private let updateTimer = Timer.publish(
        every: 30,
        on: .main,
        in: .common
    ).autoconnect()
    
    @State private var selectedType: EventType? = nil
    @State private var lastTime: String? = nil
    
    @FetchRequest(fetchRequest: MabyKit.lastEvent())
    private var lastEvent: FetchedResults<E>
    
    init(
        _ text: LocalizedStringKey,
        icon: LocalizedStringKey,
        type: EventType
    ) {
        self.text = text
        self.icon = icon
        self.type = type
    }
    
    private func updateLastTime() {
        guard let event = lastEvent.first else {
            lastTime = nil
            return
        }
        
        var eventTime: Date
        if let nursingEvent = event as? NursingEvent {
            eventTime = nursingEvent.end
        } else if let sleepEvent = event as? SleepEvent {
            eventTime = sleepEvent.end
        } else {
            eventTime = event.start
        }
        
        lastTime = eventTime.formatted(
            .relative(presentation: .named)
        )
    }
    
    private func onSelect() {
        selectedType = type
    }
    
    var body: some View {
        /// Returns true when `selectedType` contains a value. Whenever set, whether to true or false
        /// it always sets `selectedType` to nil since we are not mutating the value directly, only when
        /// closing SwiftUI will do that for us.
        let showingAddEvent = Binding(
            get: { return selectedType != nil },
            set: { _, _ in selectedType = nil }
        )
        
        return Button(action: onSelect) {
            HStack(spacing: 20) {
                Text(icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading) {
                    Text(text).padding(.horizontal, 5)
                    
                    Text(
                        lastTime == nil
                            ? "No last time"
                            : "Last time \(lastTime!)"
                    )
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
                }
                .frame(height: 50)
                .padding(.horizontal, 10)
            }
        }
        .sheet(isPresented: showingAddEvent) {
            switch selectedType! {
            case .bottle:
                AddBottleFeedEventView()
                    .sheetSize(.medium)
                .onAppear {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .onDisappear {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            case .diaper:
                AddDiaperEventView()
                    .sheetSize(.medium)
                    .onAppear {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
            case .nursing:
                AddNursingEventView()
                    .sheetSize(.height(450))
                    .onAppear {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
            case .sleep:
                AddSleepEventView()
                    .sheetSize(.medium)
                    .onAppear {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
            case .vomit:
                AddVomitEventView()
                    .sheetSize(.medium)
                    .onAppear {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
            case .breastPump:
                AddBreastPumpEventView()
                    .sheetSize(.medium)
                .onAppear {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .onDisappear {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            case .bathing:
                AddBathingEventView()
                    .sheetSize(.medium)
                .onAppear {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .onDisappear {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            case .activity:
                AddActivityEventView()
                    .sheetSize(.medium)
                .onAppear {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .onDisappear {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
        .onAppear {
            updateLastTime()
        }
        .onReceive(lastEvent.publisher) { _ in
            updateLastTime()
        }
        .onReceive(updateTimer) { _ in
            updateLastTime()
        }
    }
}
