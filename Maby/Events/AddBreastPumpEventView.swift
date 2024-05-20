import Factory
import MabyKit
import SwiftUI
import UserNotifications

struct AddBreastPumpEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var breast = BreastPumpEvent.Breast.left
    @State private var amount: Int32 = 100
    @State private var setReminder = false
    @State private var reminderInterval = 30
    
    var body: some View {
        AddEventView(
            "🥛 Breast Pumping",
            onAdd: {
                let result = eventService.addBreastPump(
                    start: startDate,
                    end: endDate,
                    breast: breast,
                    amount: amount
                )
                if setReminder, case .success(let event) = result {
                    NotificationScheduler.scheduleNotification(
                        for: event.end,
                        title: "Breast Pumping Reminder",
                        body: "It's time to pump milk.",
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
                    Text("Left").tag(BreastPumpEvent.Breast.left)
                    Text("Right").tag(BreastPumpEvent.Breast.right)
                    Text("Both").tag(BreastPumpEvent.Breast.both)
                }
                .onChange(of: breast) { newValue in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .pickerStyle(.segmented)
            }
            Section("Amount (mL)") {
                TextField("Amount in milliliters", value: $amount, format: .number)
                    .keyboardType(.numberPad)
            }
            ReminderSectionView(setReminder: $setReminder, reminderInterval: $reminderInterval)
        }
    }
}

struct AddBreastPumpEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddBreastPumpEventView()
    }
}
