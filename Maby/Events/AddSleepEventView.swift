import SwiftUI
import Factory
import MabyKit
import UserNotifications

struct AddSleepEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var setReminder = false
    @State private var reminderInterval = 15
    
    var body: some View {
        AddEventView(
            "😴 Sleep or Nap",
            onAdd: {
                let result = eventService.addSleep(start: startDate, end: endDate)
                if setReminder, case .success(let event) = result {
                    scheduleNotification(for: event, interval: reminderInterval)
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
            Section("Reminder") {
                Toggle("Set Reminder", isOn: $setReminder)
                if setReminder {
                    Picker("Reminder Interval", selection: $reminderInterval) {
                        ForEach(1..<17) { i in
                            let hours = i / 4
                            let minutes = (i % 4) * 15
                            let intervalText: String
                            if hours == 1 && minutes > 0 {
                                intervalText = "\(hours) hour \(minutes) minutes"
                            } else if hours == 1 {
                                intervalText = "\(hours) hour"
                            } else if hours > 1 && minutes > 0 {
                                intervalText = "\(hours) hours \(minutes) minutes"
                            } else if hours > 1 {
                                intervalText = "\(hours) hours"
                            } else {
                                intervalText = "\(minutes) minutes"
                            }
                            return Text(intervalText).tag(i * 15)
                        }
                    }
                }
            }
        }
    }
    
    private func scheduleNotification(for event: SleepEvent, interval: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "It's time to check on your baby's sleep."
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: interval, to: event.end)!
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
