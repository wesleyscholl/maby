import UserNotifications

struct NotificationScheduler {
    static func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }

    static func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Joyful Reminder"
        content.body = "Don't forget to add photos, videos and events to track your baby's progress!"

        var dateComponents = DateComponents()
        dateComponents.hour = Int.random(in: 9...21)
        dateComponents.minute = Int.random(in: 0...59)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    static func scheduleNotification(for eventEndDate: Date, title: String, body: String, interval: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: interval, to: eventEndDate)!
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
