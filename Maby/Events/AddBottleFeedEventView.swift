import Factory
import MabyKit
import SwiftUI
import UserNotifications

struct AddBottleFeedEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var date = Date.now
    @State private var quantity = 100
    @State private var setReminder = false
    @State private var reminderInterval = 30
    
    var body: some View {
        AddEventView(
            "🍼 Bottle Feeding",
            onAdd: {
                let result = eventService.addBottle(date: date, amount: quantity)
                if setReminder, case .success(let event) = result {
                    NotificationScheduler.scheduleNotification(
                        for: event.start,
                        title: "Bottle Feeding Reminder",
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
                    selection: $date,
                    in: Date.distantPast...Date.now
                )
            }
            Section("Amount (mL)") {
                TextField("Amount in milliliters", value: $quantity, format: .number)
                    .keyboardType(.numberPad)
            }
            ReminderSectionView(setReminder: $setReminder, reminderInterval: $reminderInterval)
        }
    }
}

struct AddBottleFeedEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddBottleFeedEventView()
    }
}

