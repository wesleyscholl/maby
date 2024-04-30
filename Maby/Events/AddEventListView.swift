import Combine
import MabyKit
import SwiftUI

struct AddEventListView: View {
    // @State private var isButtonTapped: Bool = false
    var body: some View {
        List {
            BabyCard()
            Section("Feeding") {
                AddEventButton<NursingEvent>(
                    "Add Breast Feeding",
                    icon: "🤱🏻",
                    type: .nursing
                )
                AddEventButton<BreastPumpEvent>(
                    "Add Breast Pumping",
                    icon: "🥛",
                    type: .breastPump
                )
                AddEventButton<BottleFeedEvent>(
                    "Add Bottle Feeding",
                    icon: "🍼",
                    type: .bottle
                )
            }
            Section("Hygiene") {
                AddEventButton<DiaperEvent>(
                    "Add Diaper Change",
                    icon: "🚼",
                    type: .diaper
                )
                AddEventButton<BathingEvent>(
                    "Add a Bath or Shower",
                    icon: "🛁",
                    type: .bathing
                )
            }
            Section("Health") {
                AddEventButton<SleepEvent>(
                    "Add Sleep or a Nap",
                    icon: "😴",
                    type: .sleep
                )
                AddEventButton<VomitEvent>(
                    "Add Activity",
                    icon: "🪇",
                    type: .activity
                )
                AddEventButton<VomitEvent>(
                    "Add Vomit, Burping or Spit Up",
                    icon: "🤢",
                    type: .vomit
                )
            }
        }
        // .overlay(
        //     VStack {
        //         Spacer()
        //         HStack {
        //             Spacer()
        //             Button(action: {
        //                 // Handle button tap here
        //                 isButtonTapped.toggle()
        //             }) {
        //                 Image(systemName: "photo.badge.plus")
        //                     .font(.system(size: 24))
        //                     .frame(width: 56, height: 56)
        //                     .background(Color.blue)
        //                     .foregroundColor(.white)
        //                     .cornerRadius(28)
        //                     .padding()
        //                     .shadow(color: Color.gray.opacity(0.5), radius: 0.2, x: 1, y: 1)
        //             }
        //         }
        //     }
        // )
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        // .sheet(isPresented: $isButtonTapped) {
        //             // Present your sheet here
        //     Text("Photo").font(.system(size: 30))
        // }
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
            HStack {
                Text(icon)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(text)
                    
                    Text(
                        lastTime == nil
                            ? "No last time"
                            : "Last time \(lastTime!)"
                    )
                    .font(.callout)
                    .foregroundColor(.gray)
                }
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

struct AddEventListView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventListView()
            .mockedDependencies()
    }
}
