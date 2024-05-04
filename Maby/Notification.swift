
import SwiftUI
import UserNotifications

struct NotificationView: View {
    var body: some View {
        VStack {
            // 2 schedule notification
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                let content = UNMutableNotificationContent()
//                content.title = "Joyful"
//                content.subtitle = "Keep track of your baby's progress!"
//                content.subtitle = "Joyful"
                content.body = "Add photos, record videos and more! Tap to open. How many lines can the body hold? Let's see... Crazy right? Sending local push notifications to my phone for testng."
                content.sound = UNNotificationSound.default
                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }) {
                Label("Schedule a notification", systemImage: "bell.fill")
                    .symbolRenderingMode(.multicolor)
            }.font(.subheadline)
        }
        .padding()
        .onAppear(){
            // 1 checking for permission
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Permission approved!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    NotificationView()
}
