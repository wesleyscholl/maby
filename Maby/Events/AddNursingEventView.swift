import Factory
import MabyKit
import SwiftUI
import UserNotifications

struct AddNursingEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var breast = NursingEvent.Breast.left
    @State private var setReminder = false
    @State private var reminderInterval = 30
    
    var body: some View {
        AddEventView(
            "🤱🏻 Breast Feeding",
            onAdd: {
                let result = eventService.addNursing(
                    start: startDate,
                    end: endDate,
                    breast: breast
                )
                if setReminder, case .success(let event) = result {
                    NotificationScheduler.scheduleNotification(
                        for: event.end, 
                        title: "Breast Feeding Reminder",
                        body: "Your baby is hungry, feed them now!",
                        interval: reminderInterval
                        )
                }
                return result.map { $0 as Event }
            }
        ) {
            Section("Time") {
                DatePicker(
                    "Start",
                    selection: $startDate,
                    in: Date.distantPast...Date.now
                )
                
                DatePicker(
                    "End",
                    selection: $endDate,
                    in: startDate...Date.distantFuture
                )
            }
            Section("Breast") {
                Picker("Breast", selection: $breast) {
                    Text("Left").tag(NursingEvent.Breast.left)
                    Text("Right").tag(NursingEvent.Breast.right)
                    Text("Both").tag(NursingEvent.Breast.both)
                }
                .onChange(of: breast) { newValue in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .pickerStyle(.segmented)
            }
            ReminderSectionView(setReminder: $setReminder, reminderInterval: $reminderInterval)
        }
    }
}

struct AddNursingEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddNursingEventView()
    }
}
