import SwiftUI
import Factory
import MabyKit
import UserNotifications

struct AddSleepEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var setReminder = false
    @State private var reminderInterval = 30
    
    var body: some View {
        AddEventView(
            "😴 Sleep or Nap",
            onAdd: {
                let result = eventService.addSleep(start: startDate, end: endDate)
                if setReminder, case .success(let event) = result {
                    NotificationScheduler.scheduleNotification(
                        for: event.end, 
                        title: "Sleep Reminder", 
                        body: "It's time to wake your baby up!", 
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
            ReminderSectionView(setReminder: $setReminder, reminderInterval: $reminderInterval)
        }
    }
}
